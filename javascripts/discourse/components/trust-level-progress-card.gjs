import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { and, not } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

const TRUST_LEVEL_KEYS = ["newuser", "basic", "member", "regular", "leader"];

const GAMIFICATION_RULES = [
  ["like_received", "gamification_like_received_score"],
  ["like_given", "gamification_like_given_score"],
  ["solution", "gamification_solution_score"],
  ["user_invited", "gamification_user_invited_score"],
  ["time_read", "gamification_time_read_score"],
  ["post_read", "gamification_post_read_score"],
  ["topic_created", "gamification_topic_created_score"],
  ["post_created", "gamification_post_created_score"],
  ["flag_created", "gamification_flag_created_score"],
  ["day_visited", "gamification_day_visited_score"],
  ["reaction_received", "gamification_reaction_received_score"],
  ["reaction_given", "gamification_reaction_given_score"],
  ["chat_reaction_received", "gamification_chat_reaction_received_score"],
  ["chat_reaction_given", "gamification_chat_reaction_given_score"],
  ["chat_message_created", "gamification_chat_message_created_score"],
];

function text(key, options = {}) {
  return i18n(themePrefix(`trust_level_progress.${key}`), options);
}

function levelTitle(level) {
  const key = TRUST_LEVEL_KEYS[Number(level)];
  return key ? i18n(`trust_levels.names.${key}`) : `TL${level}`;
}

function levelBadge(level) {
  return settings.theme_uploads?.[`badge_tl${Number(level)}`];
}

function metricTitle(key) {
  return text(`metrics.${key}`);
}

function percent(current, required, maximum = false) {
  if (maximum) {
    return current <= required ? 100 : 0;
  }

  if (!required) {
    return 100;
  }

  return Math.max(0, Math.min(100, Math.round((current * 100) / required)));
}

function tl3Items(details) {
  const penalties = details.penalty_counts || {};
  const timePeriod = Number(details.time_period || 0);
  const daysVisited = Number(details.days_visited || 0);
  const minDaysVisited = Number(details.min_days_visited || 0);
  const daysVisitedPercent = timePeriod
    ? Math.round((daysVisited * 100) / timePeriod)
    : 0;
  const minDaysVisitedPercent = timePeriod
    ? Math.round((minDaysVisited * 100) / timePeriod)
    : 0;

  return [
    { key: "topics_replied_to", current: details.num_topics_replied_to, required: details.min_topics_replied_to },
    { key: "topics_viewed", current: details.topics_viewed, required: details.min_topics_viewed },
    { key: "topics_viewed_all_time", current: details.topics_viewed_all_time, required: details.min_topics_viewed_all_time },
    { key: "posts_read_tl3", current: details.posts_read, required: details.min_posts_read },
    {
      key: "posts_read_days",
      current: daysVisited,
      required: minDaysVisited,
      currentText: `${daysVisitedPercent}% (${daysVisited} / ${timePeriod} ${text("days")})`,
      requiredText: `${minDaysVisitedPercent}%`,
    },
    { key: "posts_read_all_time", current: details.posts_read_all_time, required: details.min_posts_read_all_time },
    { key: "flagged_posts", current: details.num_flagged_posts, required: details.max_flagged_posts, maximum: true },
    { key: "flagged_by_users", current: details.num_flagged_by_users, required: details.max_flagged_by_users, maximum: true },
    { key: "likes_given", current: details.num_likes_given, required: details.min_likes_given },
    { key: "likes_received", current: details.num_likes_received, required: details.min_likes_received },
    { key: "likes_received_days", current: details.num_likes_received_days, required: details.min_likes_received_days },
    { key: "likes_received_users", current: details.num_likes_received_users, required: details.min_likes_received_users },
    { key: "silenced", current: penalties.silenced || 0, required: 0, maximum: true },
    { key: "suspended", current: penalties.suspended || 0, required: 0, maximum: true },
  ].map((item) => {
    const current = Number(item.current || 0);
    const required = Number(item.required || 0);
    const met = item.maximum ? current <= required : current >= required;

    return {
      ...item,
      current,
      required,
      met,
      percent: percent(current, required, item.maximum),
      currentText: item.currentText ?? String(current),
      requiredText: item.requiredText ?? (item.maximum ? text("max_count", { count: required }) : String(required)),
    };
  });
}

export default class TrustLevelProgressCard extends Component {
  @service currentUser;
  @service siteSettings;
  @tracked data;
  @tracked loading = false;
  @tracked unavailable = false;
  @tracked gamification;

  load = modifier(async () => {
    if (!this.canDisplay || this.loading || this.data || this.unavailable) {
      return;
    }

    this.loading = true;
    try {
      this.debug("request:start", { profileUser: this.profileUser?.username });
      const [progressResult, gamificationResult] = await Promise.allSettled([
        ajax("/trust-level-progress/progress.json"),
        ajax("/leaderboard/1.json?period=all"),
      ]);

      if (progressResult.status === "rejected") {
        throw progressResult.reason;
      }

      this.data = progressResult.value;
      if (gamificationResult.status === "fulfilled") {
        this.gamification = gamificationResult.value;
      } else {
        this.debug("gamification:unavailable", {
          status: gamificationResult.reason?.status,
        });
      }

      this.debug("request:success", {
        pluginVersion: this.data?.plugin_version,
        currentLevel: this.data?.current_level,
        nextLevel: this.data?.next_level,
      });
    } catch (error) {
      this.unavailable = true;
      this.debug("request:error", { status: error?.status });
    } finally {
      this.loading = false;
    }
  });

  get profileUser() {
    return this.args.model ?? this.args.user;
  }

  debug(event, details = {}) {
    if (this.siteSettings.trust_level_progress_debug_enabled) {
      console.debug(`[TrustLevelProgress] ${event}`, details);
    }
  }

  get canDisplay() {
    return Boolean(
      this.currentUser &&
        this.profileUser &&
        (this.currentUser.id === this.profileUser.id ||
          this.currentUser.username_lower === this.profileUser.username_lower ||
          this.currentUser.username === this.profileUser.username)
    );
  }

  get achievementPoints() {
    const score = this.gamification?.personal?.user?.total_score;
    return Number.isFinite(Number(score)) ? Number(score) : null;
  }

  get achievementPointsText() {
    return this.achievementPoints?.toLocaleString() ?? "";
  }

  get achievementRank() {
    const rank =
      this.gamification?.personal?.position ??
      this.gamification?.personal?.user?.position;
    return Number.isFinite(Number(rank)) ? Number(rank) : null;
  }

  get achievementRankText() {
    return this.achievementRank ? `#${this.achievementRank.toLocaleString()}` : "";
  }

  get hasGamification() {
    return this.achievementPoints !== null;
  }

  get gamificationRules() {
    return GAMIFICATION_RULES.map(([key, setting]) => ({
      key,
      label: text(`gamification_rules.${key}`),
      value: Number(settings[setting] ?? 0),
    })).filter((rule) => settings.show_zero_score_rules || rule.value !== 0);
  }

  get currentLevel() {
    return Number(this.data?.current_level ?? this.profileUser?.trust_level ?? 0);
  }

  get nextLevel() {
    return this.data?.next_level;
  }

  get currentLevelBadge() {
    return levelBadge(this.currentLevel);
  }

  get nextLevelBadge() {
    return levelBadge(this.nextLevel);
  }

  get isLocked() {
    return Boolean(this.data?.trust_level_locked);
  }

  get isMaximumLevel() {
    return this.nextLevel === null || this.currentLevel >= 4;
  }

  get isTl3() {
    return this.data?.requirements?.type === "tl3";
  }

  get timePeriod() {
    return Number(this.data?.requirements?.details?.time_period || 0);
  }

  get items() {
    if (!this.data?.requirements) {
      return [];
    }

    if (this.isTl3) {
      return tl3Items(this.data.requirements.details || {});
    }

    return (this.data.requirements.items || []).map((item) => {
      const current = Number(item.current || 0);
      const required = Number(item.required || 0);
      const met = item.met ?? current >= required;

      return {
        ...item,
        current,
        required,
        met,
        percent: percent(current, required),
        currentText: String(current),
        requiredText: String(required),
      };
    });
  }

  get overallPercent() {
    if (!this.items.length) {
      return 0;
    }

    return Math.round(
      this.items.reduce((total, item) => total + item.percent, 0) /
        this.items.length
    );
  }

  get progressStyle() {
    return htmlSafe(`width: ${this.overallPercent}%`);
  }

  <template>
    {{#if (and this.canDisplay (not this.unavailable))}}
      <div class="trust-level-progress-loader" {{this.load}}>
        {{#if this.data}}
          <section class="trust-level-progress">
            <div class="trust-level-progress__summary">
              <div class="trust-level-progress__header">
                <div class="trust-level-progress__identity">
                  <div class="trust-level-progress__eyebrow">{{text "current_level"}}</div>
                  <h2 class="trust-level-progress__level-name">
                    {{#if this.currentLevelBadge}}
                      <img
                        class="trust-level-progress__level-icon"
                        src={{this.currentLevelBadge}}
                        alt=""
                      />
                    {{/if}}
                    <span>{{levelTitle this.currentLevel}}</span>
                  </h2>
                </div>
                {{#unless this.isMaximumLevel}}
                  <strong class="trust-level-progress__percent">{{this.overallPercent}}%</strong>
                {{/unless}}
              </div>

              {{#if this.isMaximumLevel}}
                <p class="trust-level-progress__highest">{{text "highest_level"}}</p>
              {{else}}
                <div
                  class="trust-level-progress__bar"
                  role="progressbar"
                  aria-valuemin="0"
                  aria-valuemax="100"
                  aria-valuenow={{this.overallPercent}}
                >
                  <span style={{this.progressStyle}}></span>
                </div>
                <p class="trust-level-progress__next">
                  <span>{{text "progress_to_label"}}</span>
                  {{#if this.nextLevelBadge}}
                    <img
                      class="trust-level-progress__level-icon trust-level-progress__level-icon--next"
                      src={{this.nextLevelBadge}}
                      alt=""
                    />
                  {{/if}}
                  <span class="trust-level-progress__next-name">{{levelTitle this.nextLevel}}</span>
                </p>
              {{/if}}

              {{#unless this.isMaximumLevel}}
                <div class="trust-level-progress__requirements">
                  {{#if this.isLocked}}
                    <p class="trust-level-progress__warning">{{text "locked"}}</p>
                  {{/if}}

                  {{#if this.isTl3}}
                    <p class="trust-level-progress__period">
                      {{text "past_days" count=this.timePeriod}}
                    </p>
                  {{/if}}

                  <div class="trust-level-progress__table-wrap">
                    <table class="trust-level-progress__table">
                      <thead>
                        <tr>
                          <th scope="col">{{text "requirement"}}</th>
                          <th scope="col" aria-label={{text "status"}}></th>
                          <th scope="col">{{text "value"}}</th>
                          <th scope="col">{{text "required"}}</th>
                        </tr>
                      </thead>
                      <tbody>
                        {{#each this.items as |item|}}
                          <tr class={{if item.met "is-complete" "is-incomplete"}}>
                            <th scope="row">{{metricTitle item.key}}</th>
                            <td class="trust-level-progress__indicator" aria-label={{if item.met (text "complete") (text "incomplete")}}>
                              {{if item.met "✓" "×"}}
                            </td>
                            <td>{{item.currentText}}</td>
                            <td>{{item.requiredText}}</td>
                          </tr>
                        {{/each}}
                      </tbody>
                    </table>
                  </div>

                  <p class="trust-level-progress__status {{if this.data.requirements.met 'is-complete' 'is-incomplete'}}">
                    <span aria-hidden="true">{{if this.data.requirements.met "✓" "×"}}</span>
                    {{if this.data.requirements.met (text "met") (text "not_met")}}
                  </p>
                </div>
              {{/unless}}
            </div>

            {{#if this.hasGamification}}
              <section class="trust-level-progress__gamification">
                <div class="trust-level-progress__gamification-header">
                  <div>
                    <div class="trust-level-progress__eyebrow">{{text "achievement_system"}}</div>
                    <h2>{{text "achievement_points"}}</h2>
                  </div>
                  <div class="trust-level-progress__gamification-stats">
                    <div class="trust-level-progress__gamification-stat">
                      <span>{{text "achievement_points"}}</span>
                      <strong>{{this.achievementPointsText}}</strong>
                    </div>
                    {{#if this.achievementRank}}
                      <div class="trust-level-progress__gamification-stat">
                        <span>{{text "achievement_rank"}}</span>
                        <strong>{{this.achievementRankText}}</strong>
                      </div>
                    {{/if}}
                  </div>
                </div>

                <div class="trust-level-progress__rules">
                  <h3>{{text "achievement_rules"}}</h3>
                  <div class="trust-level-progress__rules-grid">
                    {{#each this.gamificationRules as |rule|}}
                      <div class="trust-level-progress__rule {{if rule.value 'is-active' 'is-disabled'}}">
                        <span>{{rule.label}}</span>
                        <strong>+{{rule.value}}</strong>
                      </div>
                    {{/each}}
                  </div>
                </div>
              </section>
            {{/if}}

          </section>
        {{/if}}
      </div>
    {{/if}}
  </template>
}

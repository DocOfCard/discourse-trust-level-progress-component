import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { service } from "@ember/service";
import { modifier } from "ember-modifier";
import { htmlSafe } from "@ember/template";
import { ajax } from "discourse/lib/ajax";
import { withPluginApi } from "discourse/lib/plugin-api";
import { and, not } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";

function text(key, options = {}) {
  return i18n(themePrefix(`trust_level_progress.${key}`), options);
}

function levelTitle(level) {
  return text(`levels.${level}`);
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

  return [
    { key: "days_visited_tl3", current: details.days_visited, required: details.min_days_visited },
    { key: "topics_replied_to", current: details.num_topics_replied_to, required: details.min_topics_replied_to },
    { key: "topics_viewed", current: details.topics_viewed, required: details.min_topics_viewed },
    { key: "topics_viewed_all_time", current: details.topics_viewed_all_time, required: details.min_topics_viewed_all_time },
    { key: "posts_read_tl3", current: details.posts_read, required: details.min_posts_read },
    { key: "posts_read_all_time", current: details.posts_read_all_time, required: details.min_posts_read_all_time },
    { key: "flagged_posts", current: details.num_flagged_posts, required: details.max_flagged_posts, maximum: true },
    { key: "flagged_by_users", current: details.num_flagged_by_users, required: details.max_flagged_by_users, maximum: true },
    { key: "likes_given", current: details.num_likes_given, required: details.min_likes_given },
    { key: "likes_received", current: details.num_likes_received, required: details.min_likes_received },
    { key: "likes_received_days", current: details.num_likes_received_days, required: details.min_likes_received_days },
    { key: "likes_received_users", current: details.num_likes_received_users, required: details.min_likes_received_users },
    { key: "silenced", current: penalties.silenced || 0, required: 0, maximum: true },
    { key: "suspended", current: penalties.suspended || 0, required: 0, maximum: true },
  ].map((item) => ({
    ...item,
    current: Number(item.current || 0),
    required: Number(item.required || 0),
    met: item.maximum ? Number(item.current || 0) <= Number(item.required || 0) : Number(item.current || 0) >= Number(item.required || 0),
    percent: percent(Number(item.current || 0), Number(item.required || 0), item.maximum),
  }));
}

class PostTrustLevelTitle extends Component {
  get title() {
    const level = this.args.post?.trust_level;
    return level === undefined || level === null ? "" : levelTitle(level);
  }

  <template>
    {{#if this.title}}
      <span class="trust-level-title-on-post">{{this.title}}</span>
    {{/if}}
  </template>
}

class TrustLevelProgressCard extends Component {
  @service currentUser;
  @tracked data;
  @tracked loading = false;
  @tracked unavailable = false;

  load = modifier(async () => {
    if (!this.canDisplay || this.loading || this.data || this.unavailable) {
      return;
    }

    this.loading = true;
    try {
      this.data = await ajax("/trust-level-progress/progress.json");
    } catch {
      // The backend plugin is optional. When its endpoint is unavailable or
      // access is denied, hide the component without exposing error details.
      this.unavailable = true;
    } finally {
      this.loading = false;
    }
  });

  get profileUser() {
    return this.args.outletArgs?.model;
  }

  get canDisplay() {
    return Boolean(
      this.currentUser &&
        this.profileUser &&
        this.currentUser.username === this.profileUser.username
    );
  }

  get currentLevel() {
    return Number(this.data?.current_level ?? this.profileUser?.trust_level ?? 0);
  }

  get nextLevel() {
    return this.data?.next_level;
  }

  get isLocked() {
    return this.data?.manual_locked_trust_level !== null &&
      this.data?.manual_locked_trust_level !== undefined;
  }

  get isMaximumLevel() {
    return this.nextLevel === null || this.currentLevel >= 4;
  }

  get items() {
    if (!this.data?.requirements) {
      return [];
    }

    if (this.data.requirements.type === "tl3") {
      return tl3Items(this.data.requirements.details || {});
    }

    return (this.data.requirements.items || []).map((item) => ({
      ...item,
      percent: percent(item.current, item.required),
    }));
  }

  get overallPercent() {
    if (!this.items.length) {
      return 0;
    }

    return Math.round(
      this.items.reduce((total, item) => total + item.percent, 0) / this.items.length
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
            <div class="trust-level-progress__header">
              <div>
                <div class="trust-level-progress__eyebrow">{{text "current_level"}}</div>
                <h2>{{levelTitle this.currentLevel}}</h2>
              </div>
              {{#unless this.isMaximumLevel}}
                <strong>{{this.overallPercent}}%</strong>
              {{/unless}}
            </div>

            {{#if this.isMaximumLevel}}
              <p>{{text "highest_level"}}</p>
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
                {{text "progress_to" level=(levelTitle this.nextLevel)}}
              </p>

              {{#if this.isLocked}}
                <p class="trust-level-progress__warning">{{text "locked"}}</p>
              {{/if}}

              <p class="trust-level-progress__status">
                {{if this.data.requirements.met (text "met") (text "not_met")}}
              </p>

              <div class="trust-level-progress__metrics">
                {{#each this.items as |item|}}
                  <div class="trust-level-progress__metric {{if item.met 'is-complete' 'is-incomplete'}}">
                    <span class="trust-level-progress__indicator" aria-hidden="true">{{if item.met "✓" "×"}}</span>
                    <span class="trust-level-progress__label">{{metricTitle item.key}}</span>
                    <strong>{{item.current}} / {{item.required}}</strong>
                  </div>
                {{/each}}
              </div>
            {{/if}}
          </section>
        {{/if}}
      </div>
    {{/if}}
  </template>
}

export default {
  name: "trust-level-progress",

  initialize() {
    withPluginApi((api) => {
      if (settings.show_title_on_posts) {
        api.addTrackedPostProperties("trust_level");
        api.renderAfterWrapperOutlet("post-meta-data-poster-name", PostTrustLevelTitle);
      }

      if (settings.show_profile_progress) {
        api.renderInOutlet("above-user-profile", TrustLevelProgressCard);
      }
    });
  },
};

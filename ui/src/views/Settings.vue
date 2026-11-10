<!--
  Copyright (C) 2026 ns8-rustdesk contributors
  SPDX-License-Identifier: GPL-3.0-or-later
-->
<template>
  <cv-grid fullWidth>
    <cv-row>
      <cv-column class="page-title">
        <h2>{{ $t("settings.title") }}</h2>
      </cv-column>
    </cv-row>
    <cv-row v-if="error.getConfiguration">
      <cv-column>
        <NsInlineNotification
          kind="error"
          :title="$t('action.get-configuration')"
          :description="error.getConfiguration"
          :showCloseButton="false"
        />
      </cv-column>
    </cv-row>
    <cv-row>
      <cv-column :lg="8">
        <cv-tile light>
          <cv-form @submit.prevent="configureModule">
            <cv-text-input
              :label="$t('settings.host')"
              :helper-text="$t('settings.host_helper')"
              placeholder="rustdesk.example.org"
              v-model.trim="host"
              class="mg-bottom"
              :invalid-message="$t(error.host)"
              :disabled="loading.getConfiguration || loading.configureModule"
              ref="host"
            />
            <cv-text-input
              :label="$t('settings.rustdesk_host')"
              :helper-text="$t('settings.rustdesk_host_helper')"
              :placeholder="host || 'rustdesk.example.org'"
              v-model.trim="rustdeskHost"
              class="mg-bottom"
              :invalid-message="$t(error.rustdesk_host)"
              :disabled="loading.getConfiguration || loading.configureModule"
              ref="rustdesk_host"
            />
            <cv-toggle
              value="letsEncrypt"
              :label="$t('settings.lets_encrypt')"
              v-model="isLetsEncryptEnabled"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </cv-toggle>
            <cv-toggle
              value="httpToHttps"
              :label="$t('settings.http_to_https')"
              v-model="isHttpToHttpsEnabled"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </cv-toggle>
            <cv-toggle
              value="webClient"
              :label="$t('settings.web_client')"
              v-model="isWebClientEnabled"
              :disabled="loading.getConfiguration || loading.configureModule"
              class="mg-bottom"
            >
              <template slot="text-left">{{
                $t("settings.disabled")
              }}</template>
              <template slot="text-right">{{
                $t("settings.enabled")
              }}</template>
            </cv-toggle>
            <h4 class="mg-bottom section-title">
              {{ $t("settings.security") }}
            </h4>
            <cv-text-input
              type="number"
              min="0"
              max="100"
              :label="$t('settings.ban_threshold')"
              :helper-text="$t('settings.ban_threshold_helper')"
              v-model.number="banThreshold"
              class="mg-bottom narrow"
              :invalid-message="$t(error.ban_threshold)"
              :disabled="loading.getConfiguration || loading.configureModule"
              ref="ban_threshold"
            />
            <cv-text-input
              type="number"
              min="0"
              max="3650"
              :label="$t('settings.log_retention_days')"
              :helper-text="$t('settings.log_retention_days_helper')"
              v-model.number="logRetentionDays"
              class="mg-bottom narrow"
              :invalid-message="$t(error.log_retention_days)"
              :disabled="loading.getConfiguration || loading.configureModule"
              ref="log_retention_days"
            />
            <cv-text-area
              :label="$t('settings.admin_allowlist')"
              :helper-text="$t('settings.admin_allowlist_helper')"
              placeholder="203.0.113.10&#10;192.168.1.0/24"
              v-model="adminAllowlist"
              class="mg-bottom"
              :invalid-message="adminAllowlistError"
              :disabled="loading.getConfiguration || loading.configureModule"
              ref="admin_allowlist"
            />
            <NsInlineNotification
              v-if="isWebClientEnabled"
              kind="info"
              :title="$t('settings.web_client_notice_title')"
              :description="$t('settings.web_client_notice')"
              :showCloseButton="false"
            />
            <NsInlineNotification
              v-if="error.configureModule"
              kind="error"
              :title="$t('action.configure-module')"
              :description="error.configureModule"
              :showCloseButton="false"
            />
            <NsButton
              kind="primary"
              :icon="Save20"
              :loading="loading.configureModule"
              :disabled="loading.getConfiguration || loading.configureModule"
              >{{ $t("settings.save") }}</NsButton
            >
          </cv-form>
        </cv-tile>
      </cv-column>
      <cv-column :lg="8">
        <cv-tile light>
          <h4 class="mg-bottom">{{ $t("settings.client_setup") }}</h4>
          <template v-if="savedHost">
            <p class="mg-bottom">
              {{ $t("settings.client_setup_description") }}
            </p>
            <div class="client-field">
              <span class="label">{{ $t("settings.id_server") }}</span>
              <!-- prettier-ignore -->
              <NsCodeSnippet hideExpandButton light>{{ savedRustdeskHost }}</NsCodeSnippet>
            </div>
            <div class="client-field">
              <span class="label">{{ $t("settings.relay_server") }}</span>
              <!-- prettier-ignore -->
              <NsCodeSnippet hideExpandButton light>{{ savedRustdeskHost }}</NsCodeSnippet>
            </div>
            <div class="client-field">
              <span class="label">{{ $t("settings.api_server") }}</span>
              <!-- prettier-ignore -->
              <NsCodeSnippet hideExpandButton light>{{ apiUrl }}</NsCodeSnippet>
            </div>
            <div class="client-field">
              <span class="label">{{ $t("settings.key") }}</span>
              <!-- prettier-ignore -->
              <NsCodeSnippet v-if="publicKey" hideExpandButton light>{{ publicKey }}</NsCodeSnippet>
              <p v-else class="hint">{{ $t("settings.key_not_ready") }}</p>
            </div>
            <NsButton kind="tertiary" :icon="Launch20" @click="openConsole">{{
              $t("settings.open_console")
            }}</NsButton>
            <NsButton
              v-if="savedWebClient"
              kind="ghost"
              :icon="Launch20"
              @click="openWebClient"
              >{{ $t("settings.open_web_client") }}</NsButton
            >
          </template>
          <p v-else class="hint">{{ $t("settings.not_configured") }}</p>
        </cv-tile>
      </cv-column>
    </cv-row>
  </cv-grid>
</template>

<script>
import to from "await-to-js";
import { mapState } from "vuex";
import {
  QueryParamService,
  UtilService,
  TaskService,
  IconService,
  PageTitleService,
} from "@nethserver/ns8-ui-lib";

export default {
  name: "Settings",
  mixins: [
    TaskService,
    IconService,
    UtilService,
    QueryParamService,
    PageTitleService,
  ],
  pageTitle() {
    return this.$t("settings.title") + " - " + this.appName;
  },
  data() {
    return {
      q: {
        page: "settings",
      },
      urlCheckInterval: null,
      host: "",
      rustdeskHost: "",
      isLetsEncryptEnabled: true,
      isHttpToHttpsEnabled: true,
      isWebClientEnabled: false,
      banThreshold: 5,
      logRetentionDays: 180,
      adminAllowlist: "",
      // values currently applied on the server
      savedHost: "",
      savedRustdeskHost: "",
      savedWebClient: false,
      publicKey: "",
      loading: {
        getConfiguration: false,
        configureModule: false,
      },
      error: {
        getConfiguration: "",
        configureModule: "",
        host: "",
        rustdesk_host: "",
        ban_threshold: "",
        log_retention_days: "",
        admin_allowlist: "",
        admin_allowlist_value: "",
      },
    };
  },
  computed: {
    ...mapState(["instanceName", "core", "appName"]),
    adminAllowlistError() {
      if (!this.error.admin_allowlist) {
        return "";
      }
      return this.$t(this.error.admin_allowlist, {
        value: this.error.admin_allowlist_value,
      });
    },
    adminAllowlistEntries() {
      return this.adminAllowlist
        .split(/[\s,]+/)
        .map((entry) => entry.trim())
        .filter((entry) => entry);
    },
    apiUrl() {
      return `https://${this.savedHost}`;
    },
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      vm.watchQueryData(vm);
      vm.urlCheckInterval = vm.initUrlBindingForApp(vm, vm.q.page);
    });
  },
  beforeRouteLeave(to, from, next) {
    clearInterval(this.urlCheckInterval);
    next();
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    openWebClient() {
      window.open(`${this.apiUrl}/webclient/`, "_blank");
    },
    openConsole() {
      window.open(`${this.apiUrl}/_admin/`, "_blank");
    },
    async getConfiguration() {
      this.loading.getConfiguration = true;
      this.error.getConfiguration = "";
      const taskAction = "get-configuration";
      const eventId = this.getUuid();

      this.core.$root.$once(
        `${taskAction}-aborted-${eventId}`,
        this.getConfigurationAborted
      );
      this.core.$root.$once(
        `${taskAction}-completed-${eventId}`,
        this.getConfigurationCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          extra: {
            title: this.$t("action." + taskAction),
            isNotificationHidden: true,
            eventId,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.getConfiguration = this.getErrorMessage(err);
        this.loading.getConfiguration = false;
        return;
      }
    },
    getConfigurationAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.getConfiguration = this.$t("error.generic_error");
      this.loading.getConfiguration = false;
    },
    getConfigurationCompleted(taskContext, taskResult) {
      this.loading.getConfiguration = false;
      const config = taskResult.output;

      this.host = config.host;
      this.rustdeskHost =
        config.rustdesk_host === config.host ? "" : config.rustdesk_host;
      this.isLetsEncryptEnabled = config.lets_encrypt;
      this.isHttpToHttpsEnabled = config.http2https;
      this.isWebClientEnabled = config.web_client;
      this.banThreshold = config.ban_threshold;
      this.logRetentionDays = config.log_retention_days;
      this.adminAllowlist = config.admin_allowlist.join("\n");
      this.savedHost = config.host;
      this.savedRustdeskHost = config.rustdesk_host;
      this.savedWebClient = config.web_client;
      this.publicKey = config.public_key;

      this.focusElement("host");
    },
    validateConfigureModule() {
      this.clearErrors(this);
      let isValidationOk = true;

      if (!this.host) {
        this.error.host = "common.required";
        this.focusElement("host");
        isValidationOk = false;
      }
      for (const [field, max] of [
        ["ban_threshold", 100],
        ["log_retention_days", 3650],
      ]) {
        const value =
          field === "ban_threshold" ? this.banThreshold : this.logRetentionDays;
        if (!Number.isInteger(value) || value < 0 || value > max) {
          this.error[field] = "settings.invalid_number";
          if (isValidationOk) {
            this.focusElement(field);
          }
          isValidationOk = false;
        }
      }
      return isValidationOk;
    },
    configureModuleValidationFailed(validationErrors) {
      this.loading.configureModule = false;
      let focusAlreadySet = false;

      for (const validationError of validationErrors) {
        const field = validationError.field;

        if (field !== "(root)") {
          this.error[field] = "settings." + validationError.error;
          if (field === "admin_allowlist") {
            this.error.admin_allowlist_value = validationError.value;
          }

          if (!focusAlreadySet) {
            this.focusElement(field);
            focusAlreadySet = true;
          }
        }
      }
    },
    async configureModule() {
      if (!this.validateConfigureModule()) {
        return;
      }

      this.loading.configureModule = true;
      const taskAction = "configure-module";
      const eventId = this.getUuid();

      this.core.$root.$once(
        `${taskAction}-aborted-${eventId}`,
        this.configureModuleAborted
      );
      this.core.$root.$once(
        `${taskAction}-validation-failed-${eventId}`,
        this.configureModuleValidationFailed
      );
      this.core.$root.$once(
        `${taskAction}-completed-${eventId}`,
        this.configureModuleCompleted
      );

      const res = await to(
        this.createModuleTaskForApp(this.instanceName, {
          action: taskAction,
          data: {
            host: this.host,
            rustdesk_host: this.rustdeskHost || this.host,
            lets_encrypt: this.isLetsEncryptEnabled,
            http2https: this.isHttpToHttpsEnabled,
            web_client: this.isWebClientEnabled,
            ban_threshold: this.banThreshold,
            log_retention_days: this.logRetentionDays,
            admin_allowlist: this.adminAllowlistEntries,
          },
          extra: {
            title: this.$t("settings.configure_instance", {
              instance: this.instanceName,
            }),
            description: this.$t("common.processing"),
            eventId,
          },
        })
      );
      const err = res[0];

      if (err) {
        console.error(`error creating task ${taskAction}`, err);
        this.error.configureModule = this.getErrorMessage(err);
        this.loading.configureModule = false;
        return;
      }
    },
    configureModuleAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.configureModule = this.$t("error.generic_error");
      this.loading.configureModule = false;
    },
    configureModuleCompleted() {
      this.loading.configureModule = false;
      this.getConfiguration();
    },
  },
};
</script>

<style scoped lang="scss">
@import "../styles/carbon-utils";

.mg-bottom {
  margin-bottom: $spacing-06;
}

.section-title {
  margin-top: $spacing-07;
}

.narrow {
  max-width: 16rem;
}

.client-field {
  margin-bottom: $spacing-05;
}

.client-field .label {
  display: block;
  margin-bottom: $spacing-02;
  font-size: 0.75rem;
  color: $text-02;
}

.hint {
  color: $text-02;
}
</style>

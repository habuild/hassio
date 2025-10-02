#!/command/with-contenv bashio
# shellcheck shell=bash
# ==============================================================================
# Setup options
# s6-overlay docs: https://github.com/just-containers/s6-overlay
# ==============================================================================

  export EMAIL="$(jq --raw-output '.NOIP_Email' $CONFIG_PATH)"
  export PASSWORD="$(jq --raw-output '.NOIP_Password' $CONFIG_PATH)"
  export NOIP_TOTPKEY="$(jq --raw-output '.NOIP_TOTP_KEY' $CONFIG_PATH)"
  export TRANSLATE="$(jq --raw-output '.Translate_Enabled' $CONFIG_PATH)"

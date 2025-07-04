local Translations = {
    error = {
        fingerprints = 'You\'ve left a fingerprint on the glass',
        minimum_police = 'Minimum of %{value} police needed',
        wrong_weapon = 'Your weapon is not strong enough..',
        to_much = 'You have to much in your pocket'
    },
    success = {},
    info = {
        progressbar = 'Smashing the washing machine',
    },
    general = {
        target_label = 'Smash the Washing Machine',
        drawtextui_grab = '[E] Smash Washing Machine',
        drawtextui_broken = 'Washing Machine is broken'
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})

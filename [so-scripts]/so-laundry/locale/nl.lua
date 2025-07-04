local Translations = {
    error = {
        fingerprints = 'Je hebt een vingerafdruk op het glas achtergelaten',
        minimum_police = 'Minimaal %{value} politie nodig',
        wrong_weapon = 'Je wapen is niet sterk genoeg..',
        to_much = 'Je hebt te veel in je zak'
    },
    success = {},
    info = {
        progressbar = 'De machine kapot maken',
    },
    general = {
        target_label = 'De machine kapot slaan',
        drawtextui_grab = '[E] machine kapot slaan',
        drawtextui_broken = 'machine is kapot'
    }
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end

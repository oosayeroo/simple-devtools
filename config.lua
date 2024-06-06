Config = {}

Config.NotifyScript = 'qb'

Config.DevMenu = {
    [1] = {
        Header = "Props",
        Event = 'sayer-devtools:TriggerPropMenu',
    },
    [2] = {
        Header = "Animations",
        Event = 'sayer-devtools:TriggerAnimMenu',
    },
    [3] = {
        Header = "Remove All",
        Event = 'sayer-devtools:RemoveAll',
    },
    [4] = {
        Header = "Set Tolerance",
        Event = 'sayer-devtools:SetTolerance',
    },
    [5] = {
        Header = "Set Alpha",
        Event = 'sayer-devtools:SetAlpha',
    },
    [6] = {
        Header = "Test Spawn",
        Event = 'sayer-devtools:TestSpawn',
    },
}

Config.OpenMenuKey = 'END'
Config.Commands = {
    --location
    ['locxup'] = {      Control = 'NUMPAD8',    Label = "Loc X Up",},
    ['locxdown'] = {    Control = 'NUMPAD5',    Label = "Loc X Down",},
    ['locyup'] = {      Control = 'NUMPAD7',    Label = "Loc Y Up",},
    ['locydown'] = {    Control = 'NUMPAD9',    Label = "Loc Y Down",},
    ['loczup'] = {      Control = 'NUMPAD4',    Label = "Loc Z Up",},
    ['loczdown'] = {    Control = 'NUMPAD6',    Label = "Loc Z Down",},
    --rotation
    ['rotxup'] = {      Control = 'NUMPAD1',    Label = "Rot X Up",},
    ['rotxdown'] = {    Control = 'NUMPAD2',    Label = "Rot X Down",},
    ['rotyup'] = {      Control = 'NUMPAD3',    Label = "Rot Y Up",},
    ['rotydown'] = {    Control = 'NUMPAD0',    Label = "Rot Y Down",},
    ['rotzup'] = {      Control = 'MULTIPLY',   Label = "Rot Z Up",},
    ['rotzdown'] = {    Control = 'SUBTRACT',   Label = "Rot Z Down",},
}

Config.Props = {
    {propname = 'firepot'},
    {propname = 'sayer_brick_warehouse'},
    {propname = 'prop_rub_tyre_01'},
    {propname = 'prop_car_door_01'},
    {propname = 'prop_car_bonnet_01'},
    {propname = 'imp_prop_impexp_trunk_01a'},
    {propname = 'sm_prop_portaglass_01'},
    {propname = 'apa_prop_yacht_glass_04'},
    {propname = 'hei_prop_yah_glass_01'},
    {propname = 'prop_glass_panel_01'},
    {propname = 'prop_glass_panel_03'},
    {propname = 'prop_jewel_glass'},
    {propname = 'xm_prop_lab_booth_glass05'},
    {propname = 'prop_bbq_1'},
    {propname = 'prop_bbq_2'},
    {propname = 'prop_bbq_3'},
    {propname = 'prop_bbq_4'},
    {propname = 'prop_bbq_5'},
}

Config.Animations = {
    ['anim@heists@box_carry@'] = {
        {anim = 'idle'},
        {anim = 'run'},
        {anim = 'walk'},
    },
    ['amb@code_human_police_investigate@idle_a'] = {
        {anim = 'idle_a'},
        {anim = 'idle_b'},
        {anim = 'idle_c'},
    },
    ['amb@code_human_police_investigate@idle_b'] = {
        {anim = 'idle_d'},
        {anim = 'idle_e'},
        {anim = 'idle_f'},
    },
}
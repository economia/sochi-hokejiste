new Tooltip!watchElements!
sorting = <[ Kanada Rusko Švédsko USA Česko Finsko Švýcarsko Slovensko Norsko Lotyšsko Rakousko Slovinsko ]>
teams_names =
    \USA
    \Kanada
    \Rusko
    \Švédsko
    \Finsko
    \Česko
    \Slovensko
    \Ukrajina
    \Lotyšsko
    \Bělorusko
    \Dánsko
    \Švýcarsko
    \Německo
    \Kazachstán
    \Rakousko
    \Norsko
    \Francie
    \Slovinsko
    \Itálie
    \NHL
    \KHL
    \SHL
    \AHL
    \NCAA
    \Bez
    \TECZ
    \TESK
    \ML
    \NL
    \DEL
    \KCH
    \EBEL
    \CHL
    \AS
    \SM
    \ES
    \1ČL
    \VHL
    \LM

team_abbrs = <[us ca ru swe fi cz sk uk lo be ne sw de ka au no fr sl it]>
teams_in =
    "v USA"
    "v Kanadě"
    "v Rusku"
    "ve Švédsku"
    "ve Finsku"
    "v Česku"
    "na Slovensku"
    "na Ukrajině"
    "v Lotyšku"
    "v Bělorusku"
    "v Dánsku"
    "ve Švýcarsku"
    "v Něměcku"
    "v Kazachstánu"
    "v Rakousku"
    "v Norsku"
    "ve Francii"
    "na Slovinsku"
    "v Itálii"
    "v National Hockey League (USA a Kanada)"
    "v Kontinentální hokejové lize (Rusko a další)"
    "ve švédské hokejové lize"
    "v American Hockey League (USA)"
    "v National College Athletic Association (USA)"
    "bez kontraktu"
    "v české Tipsport extralize"
    "v slovenské Tipsport extralize"
    "v Metal Ligaen (Dánsko)"
    "v švédské národní lize"
    "v německé hokejové lize"
    "v kazašském hokejovém šampionátu"
    "v Erste Bank hokejové lize (Rakousko)"
    "v Central hockey league (USA)"
    "v Allsvenskan (2. švédská liga)"
    "v SM Liiga (Finsko)"
    "v Elitserien (Norsko)"
    "v 1. české hokejové lize"
    "v nižší ruské hokejové lize"
    "v Ligue Magnus (Francie)"
teams_of =
    "USA"
    "Kanady"
    "Ruska"
    "Švédska"
    "Finska"
    "Česka"
    "Slovenska"
    "Ukrajiny"
    "Lotyšska"
    "Běloruska"
    "Dánska"
    "Švýcarska"
    "Německa"
    "Kazachstánu"
    "Rakouska"
    "Norska"
    "Francie"
    "Slovinska"
    "Itálie"
class Player
    (@name, @team) ->
        @team ?= "bez kontraktu"

class Nation
    (@name, index) ->
        @xIndex = null
        @yIndex = null
        @usesPlayers = []
        @providesPlayers = []
        @abbr = team_abbrs[index]
        @name_in = teams_in[index]
        @name_of = teams_of[index]
draw = (type, sourceData, container) ->
    nations_assoc = {}
    nations = for team, index in teams_names
        nations_assoc[team] = new Nation team, index
    teams = d3.csv.parse sourceData, (row) ->
        sources = for source in teams_names
            row[source] ?= ""
            joudove = row[source].split ", "
            players = for jouda in joudove
                [name, team] = jouda.replace ")" "" .split " ("
                continue unless name
                player = new Player name, team
                nations_assoc[source].providesPlayers.push player
                nations_assoc[row['Tym']].usesPlayers.push player
                player
            source = nations_assoc[source]
            {players, source}
        team = nations_assoc[row['Tym']]
        {team, sources}
    nations .= filter -> it.providesPlayers.length or it.usesPlayers.length
    nations .= sort (a, b) ->
        | b.usesPlayers.length == 0 and a.usesPlayers.length > 0 => -1
        | b.usesPlayers.length > 0 and a.usesPlayers.length == 0 => +1
        | type == \nations
            b.providesPlayers.length - a.providesPlayers.length
        | type == \teams
            iA = sorting.indexOf a.name
            iB = sorting.indexOf b.name
            switch
            | iA - iB => that
            | iA != -1 => 1
            | iB != -1 => -1
            | _ => b.providesPlayers.length - a.providesPlayers.length
    xIndex = 0
    yIndex = 0
    for nation in nations
        if nation.providesPlayers.length
            nation.yIndex = yIndex
            ++yIndex
        if nation.usesPlayers.length
            nation.xIndex = xIndex
            ++xIndex

    cells = []
    for {team, sources} in teams
        for {source, players} in sources
            cells.push {team, source, players}

    cellSide = 40
    max = Math.max ...cells.map (.players.length)
    colorRange = ['rgb(255,237,160)','rgb(254,217,118)','rgb(254,178,76)','rgb(253,141,60)','rgb(252,78,42)','rgb(227,26,28)','rgb(189,0,38)','rgb(128,0,38)']
    colorDomain = colorRange.map (d, i) -> max * i / (colorRange.length - 2)
    colorRange.unshift "rgb(255,255,255)"
    colorDomain.shift!
    colorDomain.unshift 1
    colorDomain.unshift 0

    scale = d3.scale.linear!
        ..range colorRange
        ..domain colorDomain

    container = d3.select container

    container.append \div
        ..attr \class \content
        ..selectAll \div.cell .data cells .enter!append \div
            ..attr \class \cell
            ..classed \empty (.players.length == 0)
            ..style \left -> "#{it.team.xIndex * cellSide}px"
            ..style \top  -> "#{it.source.yIndex * cellSide}px"
            ..attr \data-tooltip ->
                if it.players.length is 0
                    return void
                out = "<b>Reprezentanti #{it.team.name_of} hrající #{it.source.name_in}</b><br />"
                out += it.players.map (-> "#{it.name} (#{it.team})" ) .join "<br />" |> escape
                out
            ..style \background-color -> scale it.players.length
    container.append \div
        ..attr \class \ig-header
        ..selectAll \div.head .data nations.filter (.xIndex isnt null)
            ..enter!append \div
                ..attr \class -> "head ico #{it.abbr}"
                ..style \left -> "#{it.xIndex * cellSide}px"
                ..attr \data-tooltip (.name)
    tooltip = ->
        l = it.providesPlayers.length
        name =
            | l == 1 => "olympionik"
            | l < 5 => "olympionici"
            | _ => "olympioniků"
        "Celkem #{l} #name hraje #{it.name_in}"
    sider = container.append \div
        ..attr \class \sider
        ..selectAll \div.side .data nations.filter (.yIndex isnt null)
            ..enter!append \div
                ..attr \class ->
                    | type == \nations => "side ico #{it.abbr}"
                    | otherwise => "side abbr"
                ..style \top -> "#{it.yIndex * cellSide}px"
                ..attr \data-tooltip tooltip
                ..html ->
                    | type == \nations => null
                    | otherwise => it.name
                ..append \div
                    ..attr \class \count
                    ..html -> it.providesPlayers.length
                    ..attr \data-tooltip tooltip

draw \nations ig.data.staty, ig.containers.base

draw \teams ig.data.kluby, ig.containers.states

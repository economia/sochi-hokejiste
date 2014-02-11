new Tooltip!watchElements!
teams = <[USA Kanada Rusko Švédsko Finsko Česko Slovensko Ukrajina Lotyšsko Bělorusko Dánsko Švýcarsko Německo Kazachstán Rakousko Norsko Francie Slovinsko Itálie]>
team_abbrs = <[us ca ru sw fi cz sk uk lo be ne swe de ka au no fr sl it]>
class Player
    (@name, @team) ->
class Nation
    (@name, @abbr) ->
        @xIndex = null
        @usesPlayers = []
        @providesPlayers = []

nations_assoc = {}
nations = for team, index in teams
    nations_assoc[team] = new Nation team, team_abbrs[index]
teams = d3.csv.parse ig.data.hokejisti, (row) ->
    sources = for source in teams
        joudove = row[source].split ", "
        players = for jouda in joudove
            [name, team] = jouda.replace ")" "" .split " ("
            break unless name
            player = new Player name, team
            nations_assoc[source].providesPlayers.push player
            nations_assoc[row['Tym']].usesPlayers.push player
            player
        source = nations_assoc[source]
        {players, source}
    team = nations_assoc[row['Tym']]
    {team, sources}
cells = []
nations .= sort (a, b) ->
    | b.usesPlayers.length == 0 and a.usesPlayers.length > 0 => -1
    | b.usesPlayers.length > 0 and a.usesPlayers.length == 0 => +1
    | b.providesPlayers.length - a.providesPlayers.length => that
xIndex = 0
for nation, yIndex in nations
    nation.yIndex = yIndex
    if nation.usesPlayers.length
        nation.xIndex = xIndex
        ++xIndex

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

container = d3.select  ig.containers.base

container.append \div
    ..attr \class \content
    ..selectAll \div.cell .data cells .enter!append \div
        ..attr \class \cell
        ..classed \empty (.players.length == 0)
        ..style \left -> "#{it.team.xIndex * cellSide}px"
        ..style \top  -> "#{it.source.yIndex * cellSide}px"
        ..attr \data-tooltip ->
            out = "<b>#{it.team.name}, reprezentanti hrající ve #{it.source.name}</b><br />"
            out += it.players.map (.name) .join "<br />" |> escape
            out
        ..style \background-color -> scale it.players.length
container.append \div
    ..attr \class \header
    ..selectAll \div.head .data nations.filter (.xIndex isnt null)
        ..enter!append \div
            ..attr \class -> "head ico #{it.abbr}"
            ..style \left -> "#{it.xIndex * cellSide}px"
            ..attr \data-tooltip (.name)
container.append \div
    ..attr \class \sider
    ..selectAll \div.side .data nations
        ..enter!append \div
            ..attr \class -> "side ico #{it.abbr}"
            ..style \top -> "#{it.yIndex * cellSide}px"
            ..attr \data-tooltip (.name)

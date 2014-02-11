new Tooltip!watchElements!
teams = <[USA Kanada Rusko Švédsko Finsko Česko Slovensko Ukrajina Lotyšsko Bělorusko Dánsko Švýcarsko Německo Kazachstán Rakousko Norsko Francie Slovinsko Itálie]>
class Player
    (@name, @team) ->
class Nation
    (@name) ->
        @usesPlayers = []
        @providesPlayers = []

nations_assoc = {}
nations = for team in teams
    nations_assoc[team] = new Nation team
teams = d3.csv.parse ig.data.hokejisti, (row) ->
    sources = for source in teams
        joudove = row[source].split ", "
        players = for jouda in joudove
            [name, team] = jouda.replace ")" "" .split " ("
            player = new Player name, team
            nations_assoc[source].providesPlayers.push player
            nations_assoc[row['Tym']].usesPlayers.push player
            player
        source = nations_assoc[source]
        {players, source}
    team = nations_assoc[row['Tym']]
    {team, sources}
cells = []
nations .= sort (a, b) -> b.providesPlayers.length - a.providesPlayers.length
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
colorDomain = ['rgb(255,255,204)','rgb(255,237,160)','rgb(254,217,118)','rgb(254,178,76)','rgb(253,141,60)','rgb(252,78,42)','rgb(227,26,28)','rgb(189,0,38)','rgb(128,0,38)']
scale = d3.scale.linear!
    ..range colorDomain
    ..domain colorDomain.map (d, i) -> max * i / (colorDomain.length - 1)
console.log colorDomain.map (d, i) ->
        max * i / (colorDomain.length - 1)
container = d3.select  ig.containers.base
container.selectAll \div.cell .data cells .enter!append \div
    ..attr \class \cell
    ..style \left -> "#{it.team.xIndex * cellSide}px"
    ..style \top  -> "#{it.source.yIndex * cellSide}px"
    ..attr \data-tooltip -> it.players.map (.name) .join "<br />" |> escape
    ..style \background-color -> scale it.players.length

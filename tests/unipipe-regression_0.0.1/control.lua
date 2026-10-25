-- Load the same runtime functions into this isolated test mod's Lua state.
Config = require('__Unipipe__/config')
require('__Unipipe__/scripts/unipipe')
script.on_init(function()
  assert(Pipe.getFluidNameFromFilter(prototypes.fluid.water) == 'water')
  assert(Pipe.getFluidNameFromFilter('water') == 'water')
  assert(Pipe.getFluidNameFromFilter({fluid='water'}) == 'water')
  assert(Pipe.getFluidNameFromFilter({fluid=prototypes.fluid.water}) == 'water')
  assert(Pipe.getFluidNameFromFilter(nil) == nil)
  local s=game.surfaces[1]
  local plant=s.create_entity{name='chemical-plant',position={0,0},force='player'}
  assert(plant)
  local visited={}
  findConnectedUnipipes({{entity=plant,fluidboxIdx=plant.fluids_count+1,networkId='stale'}},{},visited,{})
  assert(next(visited)==nil)
  findConnectedUnipipes({{entity=plant,fluidboxIdx=0,networkId='zero'}},{},visited,{})
  assert(next(visited)==nil)
  plant.destroy()
  storage.start=game.tick
  log('UNIPIPE_DIRECT_PASS: real fluid prototype and stale fluidbox checks')
end)
script.on_event(defines.events.on_tick,function(ev)
  local dt=ev.tick-storage.start
  if dt==1 then
    storage.pipes={}
    local s=game.surfaces[1]
    for i,recipe in ipairs({'none','sulfur','plastic-bar','sulfuric-acid'}) do
      local x=i*20
      local c=s.create_entity{name='chemical-plant',position={x,0},force='player',raise_built=true}
      assert(c)
      if recipe~='none' then assert(c.set_recipe(recipe)) end
      for _,off in ipairs({{-1,-2},{1,-2},{-1,2},{1,2}}) do
        local e=s.create_entity{name='infinity-pipe',position={x+off[1],off[2]},force='player',raise_built=true}
        assert(e)
        table.insert(storage.pipes,e)
      end
    end
  end
  if dt==30 then
    for _,e in ipairs(storage.pipes) do e.set_infinity_pipe_filter{name='petroleum-gas',percentage=1,mode='at-least'} end
  end
  if dt==300 then log('UNIPIPE_CONNECTION_PASS: 16 chemical-plant connections survived 300 ticks') end
end)

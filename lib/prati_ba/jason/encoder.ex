defimpl Jason.Encoder,
  for: [
    UAInspector.Result,
    UAInspector.Result.Bot,
    UAInspector.Result.BotProducer,
    UAInspector.Result.Client,
    UAInspector.Result.Device,
    UAInspector.Result.OS
  ] do
  def encode(struct, opts) do
    struct
    |> Map.from_struct()
    |> Jason.Encode.map(opts)
  end
end

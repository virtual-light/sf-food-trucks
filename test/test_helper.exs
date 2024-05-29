ExUnit.start()

defmodule MobileFoodWeb.FinchBehavior do
  @callback request(%Finch.Request{}, Finch.name()) ::
              {:ok, Finch.Response.t()} | {:error, Exception.t()}
end

ExUnit.start()

Mox.defmock(MobileFoodWeb.FinchMock, for: MobileFoodWeb.FinchBehavior)

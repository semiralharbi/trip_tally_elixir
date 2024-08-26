defmodule TripTallyWeb.Router do
  use TripTallyWeb, :router

  import TripTallyWeb.UserAuth

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :private_api do
    plug :accepts, ["json"]
    plug :fetch_current_user
  end

  scope "/api", TripTallyWeb do
    pipe_through :api

    post "/users/log_in", User.UserController, :log_in
    post "/users/register", User.UserController, :register
  end

  scope "/api", TripTallyWeb do
    pipe_through [:private_api]

    put "/users/update_profile", User.UserController, :update_profile

    get "/trips/today", Trips.TripsController, :today
    resources "/trips", Trips.TripsController, except: [:new, :edit]

    resources "/expenses", Expenses.ExpenseController, except: [:new, :edit]
    get "/expenses_categories", Expenses.ExpenseController, :categories
  end
end

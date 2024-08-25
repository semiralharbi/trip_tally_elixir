alias TripTally.Expenses.Expense
alias TripTally.Repo
alias TripTally.Accounts.User
alias TripTally.Trips.Locations
alias TripTally.Trips.Trip

unique_user_email = fn -> "user#{UUID.uuid1()}@example.com" end
# Users
user1 = %User{email: unique_user_email.(), hashed_password: "Password2@"} |> Repo.insert!()

user2 =
  case Repo.get_by(User, email: "user2@example.com") do
    nil -> %User{email: "user2@example.com", hashed_password: "Password2@"} |> Repo.insert!()
    user -> user
  end

# Locations
location1 =
  case Repo.get_by(Locations, country_code: "US", city_name: "New York") do
    nil ->
      %Locations{country_code: "US", city_name: "New York", user_id: user1.id}
      |> Locations.changeset(%{})
      |> Repo.insert!()

    location ->
      location
  end

location2 =
  case Repo.get_by(Locations, country_code: "FR", city_name: "Paris") do
    nil ->
      %Locations{country_code: "FR", city_name: "Paris", user_id: user2.id}
      |> Locations.changeset(%{})
      |> Repo.insert!()

    location ->
      location
  end

# Trips
trip1 =
  %Trip{
    transport_type: "Plane",
    planned_cost: Money.new(120_000, :USD),
    date_from: Timex.to_date(Timex.now()),
    date_to: ~D[2028-04-10],
    location_id: location1.id,
    user_id: user1.id
  }
  |> Trip.changeset(%{})
  |> Repo.insert!()

_trip2 =
  %Trip{
    transport_type: "Train",
    planned_cost: Money.new(30_000, :EUR),
    date_from: ~D[2024-05-15],
    date_to: ~D[2024-05-20],
    location_id: location2.id,
    user_id: user2.id
  }
  |> Trip.changeset(%{})
  |> Repo.insert!()

# Expenses for trip1
%Expense{
  name: "Hotel Stay",
  date: ~D[2024-04-02],
  price: Money.new(450_00, :USD),
  trip_id: trip1.id,
  user_id: user1.id
}
|> Expense.changeset(%{})
|> Repo.insert!()

%Expense{
  name: "Flight Meal",
  date: ~D[2024-04-01],
  price: Money.new(50_00, :USD),
  trip_id: trip1.id,
  user_id: user1.id
}
|> Expense.changeset(%{})
|> Repo.insert!()

%Expense{
  name: "Museum Tickets",
  date: ~D[2024-04-05],
  price: Money.new(30_00, :USD),
  trip_id: trip1.id,
  user_id: user1.id
}
|> Expense.changeset(%{})
|> Repo.insert!()

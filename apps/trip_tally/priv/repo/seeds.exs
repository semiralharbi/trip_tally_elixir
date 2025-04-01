defmodule TripTally.Repo.Seeds do
  alias TripTally.Expenses.{Expense, Category}
  alias TripTally.Repo
  alias TripTally.Accounts.User
  alias TripTally.Trips.{Locations, Trip}
  alias Money

  @usernames ["Explorer", "Traveler", "Adventurer", "Nomad", "Wanderer"]

  defp random_username do
    Enum.random(@usernames) <> "#{Enum.random(1..1000)}"
  end

  defp random_currency do
    Enum.random(["USD", "EUR", "GBP", "JPY"])
  end

  defp random_country do
    Enum.random(["US", "FR", "DE", "JP"])
  end

  defp unique_user_email do
    "user#{Enum.random(0..1000)}@example.com"
  end

  def seed_user(email, password \\ "Password2@") do
    case Repo.get_by(User, email: email) do
      nil ->
        %User{
          email: email,
          username: random_username(),
          hashed_password: Bcrypt.hash_pwd_salt(password),
          country: random_country(),
          default_currency_code: random_currency()
        }
        |> Repo.insert!()

      user ->
        user
    end
  end

  def seed_location(country_code, city_name, user_id) do
    case Repo.get_by(Locations, country_code: country_code, city_name: city_name) do
      nil ->
        %Locations{country_code: country_code, city_name: city_name, user_id: user_id}
        |> Locations.changeset(%{})
        |> Repo.insert!()

      location ->
        location
    end
  end

  def seed_trip(transport_type, planned_cost, date_from, date_to, location_id, user_id) do
    %Trip{
      transport_type: transport_type,
      planned_cost: planned_cost,
      date_from: date_from,
      date_to: date_to,
      location_id: location_id,
      user_id: user_id
    }
    |> Trip.changeset(%{})
    |> Repo.insert!()
  end

  def seed_expense(name, date, price, trip_id, user_id, category_id) do
    %Expense{
      name: name,
      date: date,
      price: price,
      trip_id: trip_id,
      user_id: user_id,
      category_id: category_id
    }
    |> Expense.changeset(%{})
    |> Repo.insert!()
  end

  @categories [
    %{name: "Airfare", translation_key: "ExpenseCategory.airfare"},
    %{name: "Car Rental", translation_key: "ExpenseCategory.car_rental"},
    %{name: "Fuel", translation_key: "ExpenseCategory.fuel"},
    %{name: "Parking", translation_key: "ExpenseCategory.parking"},
    %{name: "Tolls", translation_key: "ExpenseCategory.tolls"},
    %{name: "Public Transport", translation_key: "ExpenseCategory.public_transport"},
    %{name: "Taxi", translation_key: "ExpenseCategory.taxi"},
    %{name: "Accommodation", translation_key: "ExpenseCategory.accommodation"},
    %{name: "Restaurants", translation_key: "ExpenseCategory.restaurants"},
    %{name: "Groceries", translation_key: "ExpenseCategory.groceries"},
    %{name: "Attractions", translation_key: "ExpenseCategory.attractions"},
    %{name: "Tours", translation_key: "ExpenseCategory.tours"},
    %{name: "Activities", translation_key: "ExpenseCategory.activities"},
    %{name: "Souvenirs", translation_key: "ExpenseCategory.souvenirs"},
    %{name: "Clothing", translation_key: "ExpenseCategory.clothing"},
    %{name: "Local Products", translation_key: "ExpenseCategory.local_products"},
    %{name: "Medications", translation_key: "ExpenseCategory.medications"},
    %{name: "Travel Insurance", translation_key: "ExpenseCategory.travel_insurance"},
    %{name: "Visas and Fees", translation_key: "ExpenseCategory.visas_and_fees"},
    %{name: "Phone Communication", translation_key: "ExpenseCategory.phone_communication"},
    %{name: "Currency Exchange Fees", translation_key: "ExpenseCategory.currency_exchange_fees"},
    %{name: "Unexpected Expenses", translation_key: "ExpenseCategory.unexpected_expenses"}
  ]

  def seed_categories do
    Enum.map(@categories, fn category_attrs ->
      %Category{}
      |> Category.changeset(category_attrs)
      |> Repo.insert!()
    end)
  end

  def run do
    categories = seed_categories()

    user1 = seed_user(unique_user_email())
    user2 = seed_user("user2@example.com")

    location1 = seed_location("US", "New York", user1.id)
    location2 = seed_location("FR", "Paris", user2.id)

    trip1 =
      seed_trip(
        "Plane",
        Money.new(120_000, :USD),
        Timex.to_date(Timex.now()),
        ~D[2028-04-10],
        location1.id,
        user1.id
      )

    seed_trip(
      "Train",
      Money.new(30_000, :EUR),
      ~D[2024-05-15],
      ~D[2024-05-20],
      location2.id,
      user2.id
    )

    category_ids = Enum.map(categories, & &1.id)

    seed_expense(
      "Hotel Stay",
      ~D[2024-04-02],
      Money.new(450_00, :USD),
      trip1.id,
      user1.id,
      Enum.random(category_ids)
    )

    seed_expense(
      "Flight Meal",
      ~D[2024-04-01],
      Money.new(50_00, :USD),
      trip1.id,
      user1.id,
      Enum.random(category_ids)
    )

    seed_expense(
      "Museum Tickets",
      ~D[2024-04-05],
      Money.new(30_00, :USD),
      trip1.id,
      user1.id,
      Enum.random(category_ids)
    )
  end
end

TripTally.Repo.Seeds.run()

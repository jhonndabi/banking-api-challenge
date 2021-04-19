defmodule BankingApiChallenge.Credentials.Schemas.Password do
  @moduledoc """
  The password schema.
  """
  use Ecto.Schema

  import Ecto.Changeset

  alias BankingApiChallenge.Users.Schemas.User

  @default_algorithm "argon2"
  @default_salt 16
  @allowed_algorithms ~w(argon2 bcrypt pbkdf2)

  @required [:password, :hashed_value]
  @optional [:algorithm, :salt]

  @password_min_length 8

  @derive {Jason.Encoder, except: [:__meta__]}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "passwords" do
    field :password, :string, virtual: true, redact: true
    field :hashed_value, :string, redact: true
    field :algorithm, :string, default: @default_algorithm
    field :salt, :integer, default: @default_salt

    belongs_to :user, User

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, params) do
    model
    |> cast(params, @required ++ @optional)
    |> validate_inclusion(:algorithm, @allowed_algorithms)
    |> hash_password()
    |> validate_required(@required)
    |> validate_length(:password, min: @password_min_length)
  end

  defp hash_password(
         %Ecto.Changeset{
           valid?: true,
           changes: %{password: password} = changes
         } = changeset
       )
       when is_binary(password) do
    algorithm = Map.get(changes, :algorithm, @default_algorithm)
    salt = Map.get(changes, :salt, @default_salt)

    hashed_value =
      case algorithm do
        "argon2" -> Argon2.hash_pwd_salt(password, salt_len: salt)
        "bcrypt" -> Bcrypt.hash_pwd_salt(password, salt_len: salt)
        "pbkdf2" -> Pbkdf2.hash_pwd_salt(password, salt_len: salt)
      end

    put_change(changeset, :hashed_value, hashed_value)
  end

  defp hash_password(%Ecto.Changeset{} = changeset), do: changeset
end

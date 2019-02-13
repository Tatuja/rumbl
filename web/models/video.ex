defmodule Rumbl.Video do
    use Rumbl.Web, :model

    @primary_key {:id, Rumbl.Permalink, autogenerate: true}
    
    schema "videos" do
      field :url, :string
      field :title, :string
      field :description, :string
      belongs_to :user, Rumbl.User
      belongs_to :category, Rumbl.Category
      field :slug, :string

      timestamps()
    end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  @required_fields ~w(url title description)a  #a makes list of atoms (with ~w only)
  @optional_fields ~w(category_id)a


#cast, assoc_contraint, get_change, put_change are functions defined in Ecto.Changeset
    def changeset(model, params \\ %{}) do
        model
        |> cast(params, @required_fields ++ @optional_fields)
        |> validate_required(@required_fields)
        |> slugify_title()
        |> assoc_constraint(:category)
    end

    defp slugify_title(changeset) do
        if title = get_change(changeset, :title) do
            put_change(changeset, :slug, slugify(title))
        else
            changeset
        end
    end

    defp slugify(str) do
        str
        |> String.downcase()
        |> String.replace(~r/[^\w-]+/u, "-")
    end

    defimpl Phoenix.Param, for: Rumbl.Video do
        def to_param(%{slug: slug, id: id}) do
            "#{id}-#{slug}"
        end
    end
end

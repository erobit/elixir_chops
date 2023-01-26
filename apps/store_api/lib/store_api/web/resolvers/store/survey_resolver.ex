defmodule StoreAPI.Resolvers.Survey do
  alias Store

  def save(survey, %{context: %{employee: employee}}) do
    location_ids =
      employee.locations
      |> Enum.filter(fn l -> l.is_active end)
      |> Enum.map(fn l -> l.id end)

    case Enum.member?(location_ids, survey.location_id) do
      true ->
        survey
        |> Map.put(:business_id, employee.business_id)
        |> Store.save_survey()

      false ->
        {:error, "Forbidden"}
    end
  end

  def get_survey(%{id: id}, %{context: %{employee: employee}}) do
    Store.get_survey(id, employee.business_id)
  end

  def get_paged(%{location_id: location_id, options: options}, %{
        context: %{employee: employee}
      }) do
    location_ids =
      employee.locations |> Enum.filter(fn l -> l.is_active end) |> Enum.map(fn l -> l.id end)

    case Enum.member?(location_ids, location_id) do
      true -> Store.get_surveys(employee.business_id, location_id, %{options: options})
      false -> {:error, "Forbidden"}
    end
  end

  def save_submission(%{code: code, answers: answers}, _) do
    Store.save_submission(code, answers)
  end

  def get_survey_by_code(%{code: code}, %{context: %{subdomain: subdomain}}) do
    Store.get_survey(%{code: code, subdomain: subdomain})
  end

  def get_survey_submissions(options \\ %{options: %{page: %{offset: 0, limit: 0}}}, %{
        context: %{employee: employee}
      }) do
    Store.get_survey_submissions(employee.business_id, options)
  end

  def get_survey_submission(%{survey_submission_id: survey_submission_id}, %{
        context: %{employee: employee}
      }) do
    Store.get_survey_submission(survey_submission_id, employee.business_id)
  end
end

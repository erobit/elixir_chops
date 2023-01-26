defmodule Store.Notify do
  use Store.Model

  # API

  def get_notifications(options, employee_id) do
    Notification.get_employee_notifications(employee_id, options)
  end

  def get_notification_preferences(employee_id, role) do
    Notification.get_notification_preferences(employee_id, role)
  end

  def save_notification(notification, employee_id) do
    notification = Map.put(notification, :employee_id, employee_id)
    Notification.create(notification)
  end

  def save_preference(type, disabled, employee_id) do
    Notification.save_preference(type, disabled, employee_id)
  end

  def mark_all_as_read(employee_id) do
    Notification.mark_all_as_read(employee_id)
  end

  def count_unread_notifications(employee_id) do
    Notification.count_unread_notifications(employee_id)
  end

  # Features

  def notify_customer_joined_shop(customer_id, location_id) do
    get_employees(location_id)
    |> Notification.notify(%{
      type: "customer_joined_shop",
      metadata: %{customer_id: customer_id},
      location_id: location_id
    })
  end

  def customer_generated_referral_link(customer_id, location_id) do
    get_employees(location_id)
    |> Notification.notify(%{
      type: "referral_sent",
      metadata: %{customer_id: customer_id},
      location_id: location_id
    })
  end

  def customer_created_review(customer_id, location_id, review_id) do
    get_employees(location_id)
    |> Notification.notify(%{
      type: "new_review",
      metadata: %{customer_id: customer_id, review_id: review_id},
      location_id: location_id
    })
  end

  def customer_updated_review(customer_id, location_id, review_id) do
    get_employees(location_id)
    |> Notification.notify(%{
      type: "updated_review",
      metadata: %{customer_id: customer_id, review_id: review_id},
      location_id: location_id
    })
  end

  # Utility

  defp get_employees(location_id) do
    Business.get_by_location_id(location_id)
    |> Map.get(:id)
    |> Employee.get_all_by_location(location_id)
  end
end

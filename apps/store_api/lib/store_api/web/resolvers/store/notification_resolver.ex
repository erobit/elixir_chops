defmodule StoreAPI.Resolvers.Notification do
  alias Store.{Notify}

  def get_notifications(%{options: options}, %{context: %{employee: employee}}) do
    Notify.get_notifications(options, employee.id)
  end

  def get_notification_preferences(_, %{context: %{employee: employee}}) do
    Notify.get_notification_preferences(employee.id, employee.role)
  end

  def save_notification(notification, %{context: %{employee: employee}}) do
    Notify.save_notification(notification, employee.id)
  end

  def save_preference(%{type: type, disabled: disabled}, %{context: %{employee: employee}}) do
    Notify.save_preference(type, disabled, employee.id)
  end

  def mark_all_as_read(_, %{context: %{employee: employee}}) do
    Notify.mark_all_as_read(employee.id)
  end

  def count_unread_notifications(_, %{context: %{employee: employee}}) do
    Notify.count_unread_notifications(employee.id)
  end
end

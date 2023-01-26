defmodule Store.Model do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query
      alias Ecto.Multi

      alias Store.{
        AdminEmployee,
        AdminEmployeeReset,
        AuthorizationToken,
        Business,
        Customer,
        CustomerEmail,
        CustomerExportLog,
        CustomerFeedback,
        CustomerImport,
        CustomerNote,
        CustomerNoteMetadata,
        CustomerNotify,
        CustomerReset,
        DailyHours,
        DaysOfWeek,
        Employee,
        EmployeeEmail,
        EmployeeReset,
        History,
        Location,
        Notification,
        Repo,
        Review,
        Survey,
        SurveySubmission,
        Timezone,
        Visit
      }

      alias Store.Loyalty.{
        Membership,
        MemberGroup,
        Transaction,
        Reward,
        CustomerReward,
        CustomerDeal,
        Referral,
        ReferralLink,
        Deal,
        MembershipLocation,
        OptLog
      }

      alias Store.Inventory.{
        Category,
        Product,
        PricingTier,
        PricingPreference,
        CustomerProduct
      }

      alias Store.Inventory.Integration.{
        ProductIntegration,
        ProductSyncItem
      }

      alias Store.Messaging.{
        Campaign,
        CampaignProduct,
        CampaignEvent,
        SMSLog,
        SMSSetting,
        SMS
      }

      alias Store.Notify.{
        Notification
      }
    end
  end
end

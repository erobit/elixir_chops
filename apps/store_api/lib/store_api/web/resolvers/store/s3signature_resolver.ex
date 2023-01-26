defmodule StoreAPI.Resolvers.S3Signature do
  alias Store.S3Signature

  # http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html

  def sign(_, %{context: %{employee: employee}}) do
    path = "#{employee.business_id}/images/"
    mimetype = "image/"

    case S3Signature.sign(path, mimetype, :s3_shops) do
      {:error, error} -> {:error, error}
      {:ok, payload} -> {:ok, payload}
    end
  end

  def sign(_, %{context: %{customer: customer}}) do
    path = "#{customer.id}/images/"
    mimetype = "image/"

    case S3Signature.sign(path, mimetype, :s3_customers) do
      {:error, error} -> {:error, error}
      {:ok, payload} -> {:ok, payload}
    end
  end
end

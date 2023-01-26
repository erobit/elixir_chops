defmodule Store.S3Signature do
  import Timex

  # http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html
  def sign(path, mimetype, a_bucket) do
    date = :calendar.universal_time()
    credential = get_aws_credential(date, a_bucket)
    policy = policy(path, mimetype, date, credential, a_bucket)

    payload = %{
      key: path,
      content_type: mimetype,
      acl: "public-read",
      action: bucket_url(a_bucket),
      bucket: bucket_name(a_bucket),
      access_key: aws_access_key_id(a_bucket),
      credential: credential,
      policy: policy,
      signature: generate_signature(date(date), policy, a_bucket),
      date: amz_date(date),
      timestamp: :os.system_time(:micro_seconds)
    }

    {:ok, payload}
  end

  # and here's our policy - we just provide an expiration and some conditions
  defp policy(key, mimetype, date, credential, a_bucket, expiration_window \\ 60) do
    %{
      # This policy is valid for an hour by default.
      expiration: date_plus(date, expiration_window),
      conditions: [
        # You can only upload to the bucket we specify.
        %{bucket: bucket_name(a_bucket)},
        # The uploaded file must be publicly readable.
        %{acl: "public-read"},
        # You have to upload the mime type you said you would upload.
        ["starts-with", "$Content-Type", mimetype],
        # You have to upload the file name you said you would upload.
        ["starts-with", "$key", key],
        # When things work out ok, AWS should send a 201 response.
        %{"x-amz-server-side-encryption": "AES256"},
        %{"x-amz-credential": credential},
        %{"x-amz-algorithm": "AWS4-HMAC-SHA256"},
        %{"x-amz-date": amz_date(date)}
      ]
    }
    # Let's make this into JSON.
    |> Poison.encode!()
    # We also need to base64 encode it.
    |> Base.encode64()
  end

  defp generate_signature(date, policy, a_bucket) do
    key = aws_secret_key(a_bucket)
    zone = aws_zone(a_bucket)

    date
    |> kDate(key)
    |> kRegion(zone)
    |> kService("s3")
    |> kSigning
    |> ship_it(policy)
  end

  defp ship_it(key, policy) do
    :crypto.hmac(:sha256, key, policy)
    |> Base.encode16(case: :lower)
  end

  def kDate(date, key) do
    :crypto.hmac(:sha256, "AWS4" <> key, date)
  end

  def kRegion(kDate, region) do
    :crypto.hmac(:sha256, kDate, region)
  end

  def kService(kRegion, service) do
    :crypto.hmac(:sha256, kRegion, service)
  end

  def kSigning(kService) do
    :crypto.hmac(:sha256, kService, "aws4_request")
  end

  def amz_date({date, time}) do
    date = date |> quasi_iso_format
    time = time |> quasi_iso_format

    [date, "T", time, "Z"]
    |> IO.iodata_to_binary()
  end

  def quasi_iso_format({y, m, d}) do
    [y, m, d]
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(&zero_pad/1)
  end

  defp zero_pad(<<_>> = val), do: "0" <> val
  defp zero_pad(val), do: val

  defp date_plus(date, minutes) do
    date
    |> Timex.shift(minutes: minutes)
    |> format!("{ISO:Extended:Z}")
  end

  defp get_aws_credential(date, a_bucket) do
    "#{aws_access_key_id(a_bucket)}/#{date(date)}/#{aws_zone(a_bucket)}/s3/aws4_request"
  end

  defp date({date, _time}) do
    date |> quasi_iso_format
  end

  defp aws_zone(a_bucket) do
    Application.get_env(:store, a_bucket)[:zone]
  end

  defp bucket_name(a_bucket) do
    bucket = Application.get_env(:store, a_bucket)[:bucket_name]

    case System.get_env("ENV") do
      "prod" -> bucket
      "demo" -> bucket <> "-demo"
      "staging" -> bucket <> "-staging"
      _ -> bucket <> "-develop"
    end
  end

  defp bucket_url(a_bucket) do
    "https://#{bucket_name(a_bucket)}.s3.#{aws_zone(a_bucket)}.amazonaws.com/"
  end

  def aws_access_key_id(a_bucket) do
    Application.get_env(:store, a_bucket)[:access_key_id]
  end

  defp aws_secret_key(a_bucket) do
    Application.get_env(:store, a_bucket)[:secret_key]
  end
end

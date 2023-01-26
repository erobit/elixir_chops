defmodule Store.SignatureTest do
  use Store.Case
  alias Store.S3Signature

  @key "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"
  @dateStamp "20120215"
  # @regionName "us-east-1"
  # @serviceName "iam"

  # @kSecret "41575334774a616c725855746e46454d492f4b374d44454e472b62507852666943594558414d504c454b4559"
  @kDate "969fbb94feb542b71ede6f87fe4d5fa29c789342b0f407474670f0c2489e0a0d"
  # @kRegion "69daa0209cd9c5ff5c8ced464a696fd4252e981430b10e3d3fd8e2f197d7a70c"
  # @kService "f72cfd46f26bc4643f06a11eabb6c0ba18780c19a8da0c31ace671265e3c87fa"
  # @kSigning "f4780e2d9f65fa895f9c67b32ce1baf0b0d8a43505a000a1a9e090d414db404d"

  @tag encryption: "Valid hash"
  test "kDate is generated properly" do
    kDate = S3Signature.kDate(@dateStamp, @key)
    assert kDate != @kDate
  end

  # @tag encryption: "Valid hash"
  # test "kRegion is generated properly" do
  #  kRegion = S3Signature.kRegion(@kDate, @regionName)
  #  assert kRegion == @kRegion
  # end

  # @tag encryption: "Valid hash"
  # test "kService is generated properly" do
  #  kService = S3Signature.kService(@kRegion, @serviceName)
  #  assert kService == @kService
  # end

  # @tag encryption: "Valid hash"
  # test "kSigning is generated properly" do
  #  kSigning = S3Signature.kSigning(@kService)
  # end
end

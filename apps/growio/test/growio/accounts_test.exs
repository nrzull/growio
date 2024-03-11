defmodule Growio.AccountsTest do
  use Growio.DataCase
  alias Growio.Accounts
  alias Growio.Accounts.Account
  alias Growio.AccountsFixture

  @valid_phone "+1234567"

  describe "Account" do
    test "should create an account with phone #{@valid_phone}" do
      valid_phone = @valid_phone

      assert match?(
               {:ok, %Accounts.Account{phone: ^valid_phone}},
               Accounts.create_account(%{phone: valid_phone})
             )
    end

    test "should get an account by phone #{@valid_phone}" do
      %Account{phone: phone} = AccountsFixture.account!(phone: @valid_phone)

      assert match?(
               %Account{phone: ^phone},
               Accounts.get_account_by(:phone, phone)
             )
    end

    test "should get an account by id" do
      %Account{id: id} = AccountsFixture.account!(phone: @valid_phone)

      assert match?(
               %Account{id: ^id},
               Accounts.get_account_by(:id, id)
             )
    end
  end
end

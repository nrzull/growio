defmodule Growio.AccountsTest do
  use Growio.DataCase
  alias Growio.Accounts
  alias Growio.Accounts.Account
  alias Growio.AccountsFixture

  @valid_email "user@example.com"

  describe "Account" do
    test "should create an account with email #{@valid_email}" do
      valid_email = @valid_email

      assert match?(
               {:ok, %Accounts.Account{email: ^valid_email}},
               Accounts.create_account(%{email: valid_email})
             )
    end

    test "should get an account by email #{@valid_email}" do
      %Account{email: email} = AccountsFixture.account!(email: @valid_email)

      assert match?(
               %Account{email: ^email},
               Accounts.get_account_by(:email, email)
             )
    end

    test "should get an account by id" do
      %Account{id: id} = AccountsFixture.account!(email: @valid_email)

      assert match?(
               %Account{id: ^id},
               Accounts.get_account_by(:id, id)
             )
    end
  end
end

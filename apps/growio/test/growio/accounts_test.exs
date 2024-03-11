defmodule Growio.AccountsTest do
  use Growio.DataCase
  alias Growio.Accounts
  alias Growio.Accounts.Account
  alias Growio.Accounts.AccountEmailConfirmation
  alias Growio.AccountsFixture

  @valid_email "user@example.com"

  describe "Account" do
    test "should create with email #{@valid_email}" do
      valid_email = @valid_email

      assert match?(
               {:ok, %Accounts.Account{email: ^valid_email}},
               Accounts.create_account(%{email: valid_email})
             )
    end

    test "should get by email #{@valid_email}" do
      %Account{email: email} = AccountsFixture.account!(email: @valid_email)

      assert match?(
               %Account{email: ^email},
               Accounts.get_account_by(:email, email)
             )
    end

    test "should get by id" do
      %Account{id: id} = AccountsFixture.account!(email: @valid_email)

      assert match?(
               %Account{id: ^id},
               Accounts.get_account_by(:id, id)
             )
    end
  end

  describe "AccountEmailConfirmation" do
    test "should create with email" do
      result = Accounts.create_account_email_confirmation(%{email: @valid_email})

      assert match?(
               {:ok, %AccountEmailConfirmation{}},
               result
             )

      result2 = Accounts.create_account_email_confirmation(%{email: @valid_email})

      assert result == result2
    end
  end
end

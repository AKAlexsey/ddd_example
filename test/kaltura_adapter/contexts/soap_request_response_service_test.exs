defmodule CtiKaltura.ProgramScheduling.SoapRequestResponseServiceTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.ProgramScheduling.SoapRequestResponseService

  describe "#split_result" do
    test "Split right #1" do
      responses_list = [{:ok, "one"}, {:ok, "two"}, {:ok, "three"}]
      standard = {["one", "two", "three"], []}
      assert standard == SoapRequestResponseService.split_result(responses_list)
    end

    test "Split right #2" do
      responses_list = [{:ok, "one"}, {:error, {"fail_response", %{a: 1, b: 2}}}, {:ok, "three"}]

      standard =
        {["one", "three"],
         ["Error occurred: #{inspect("fail_response")} with params: #{inspect(%{a: 1, b: 2})}"]}

      assert standard == SoapRequestResponseService.split_result(responses_list)
    end

    test "Split right #3" do
      responses_list = [
        {:error, {"fail_response 1", %{a: 1, b: 2}}},
        {:error, {"fail_response 2", %{a: 1, b: 2}}},
        {:error, {"fail_response 3", %{a: 7, b: 6}}}
      ]

      standard = {
        [],
        [
          ~s(Error occurred: #{inspect("fail_response 1")} with params: #{inspect(%{a: 1, b: 2})}),
          ~s(Error occurred: #{inspect("fail_response 2")} with params: #{inspect(%{a: 1, b: 2})}),
          ~s(Error occurred: #{inspect("fail_response 3")} with params: #{inspect(%{a: 7, b: 6})})
        ]
      }

      assert standard == SoapRequestResponseService.split_result(responses_list)
    end

    test "Return tuple with empty lists if empty list given" do
      assert {[], []} = SoapRequestResponseService.split_result([])
    end

    test "Raise error if params does not fit to {:ok, response}, {:error, {response, params}} format #1" do
      responses_list = [{:error, "fail_response 1"}]

      assert_raise FunctionClauseError, fn ->
        SoapRequestResponseService.split_result(responses_list)
      end
    end

    test "Raise error if params does not fit to {:ok, response}, {:error, {response, params}} format #2" do
      responses_list = [{:okk, "one"}]

      assert_raise FunctionClauseError, fn ->
        SoapRequestResponseService.split_result(responses_list)
      end
    end
  end
end

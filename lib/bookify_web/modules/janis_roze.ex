defmodule BookifyWeb.Modules.JanisRoze do
  import Meeseeks.XPath
  import Meeseeks.CSS

  use Tesla
  alias Floki

  @api_base_url "https://api.scraperapi.com/"
  @language "lv"

  @search_url "https://www.janisroze.lv/#{@language}/catalogsearch/result/index/"
  @book_category 820

  def client() do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, @api_base_url},
      Tesla.Middleware.JSON
    ])
  end

  def fetch_search_results(query) do
    params = %{
      "api_key" => System.get_env("SCRAPER_API_KEY"),
      "url" => "#{@search_url}?cat=#{@book_category}&q=#{URI.encode(query)}",
      "render" => "true",
      "wait_for_selector" => ".product-items",
      "device_type" => "desktop",
      "country_code" => "eu",
      "max_cost" => "10"
    }

    case Tesla.get(client(), "/", query: params) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        parse_search_results(body)

      {:ok, %Tesla.Env{body: _body}} ->
        {:error, "Something went wrong"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def fetch_book_details(url, image_url) do
    params = %{
      "api_key" => System.get_env("SCRAPER_API_KEY"),
      "url" => url,
      "render" => "true",
      "wait_for_selector" => ".breadcrumbs",
      "device_type" => "desktop",
      "country_code" => "eu",
      "max_cost" => "10"
    }

    case Tesla.get(client(), "/", query: params) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        parse_detail_results(body, image_url)

      {:ok, %Tesla.Env{body: _body}} ->
        {:error, "Something went wrong"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_detail_results(html, image_url) do
    {:ok, filename} = save_book_cover_image(image_url)

    case extract_detail_data(html, filename) do
      {:ok, book_data} ->
        book_params = format_book_params(book_data)
        {:ok, book_params}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_search_results(html) do
    {:ok, document} = Floki.parse_document(html)

    books =
      Floki.find(document, ".product-item")
      |> Enum.map(fn book_element ->
        %{
          title:
            Floki.text(Floki.find(book_element, ".product-item-link"))
            |> String.trim()
            |> String.replace("\n", ""),
          link:
            Floki.attribute(book_element, ".product-item-link", "href")
            |> List.first(),
          image_url: Floki.attribute(book_element, "img", "src") |> List.first()
        }
      end)

    {:ok, books}
  end

  defp extract_detail_data(document, filename) do
    image_path = "/images/covers/#{filename}"
    breadcrumbs_xpath = "//*[@id='html-body']/div[3]/div[1]"

    title_xpath =
      "//*[@id='maincontent']/div[2]/div/div[1]/div[2]/div/div/div[2]/div/div[1]/div/h1"

    table_xpath = "//*[@id='product-attribute-specs-table']/tbody"
    anotation_xpath = "//*[@id='description']/div/div"

    breadcrumbs = Meeseeks.one(document, xpath(breadcrumbs_xpath))

    if breadcrumbs != nil do
      table = Meeseeks.one(document, xpath(table_xpath))
      table_rows = Meeseeks.all(table, css("tr"))

      title =
        Meeseeks.one(document, xpath(title_xpath))
        |> Meeseeks.text()
        |> String.trim()

      anotation =
        Meeseeks.one(document, xpath(anotation_xpath))
        |> Meeseeks.text()
        |> String.trim()

      book =
        Enum.reduce(table_rows, %{}, fn row, acc ->
          key =
            row
            |> Meeseeks.one(css("th"))
            |> Meeseeks.text()
            |> String.trim()
            |> String.replace(" ", "_")
            |> String.downcase()

          value =
            row
            |> Meeseeks.one(css("td"))
            |> Meeseeks.text()
            |> String.trim()

          Map.put(acc, key, value)
        end)

      book =
        book
        |> Map.put("anotation", anotation)
        |> Map.put("title", title)
        |> Map.put("cover_image_url", image_path)
        |> Map.put("genres", extract_generes(breadcrumbs))

      {:ok, book}
    else
      {:error, "Breadcrumb not found"}
    end
  end

  defp format_book_params(book_data) do
    if @language == "lv" do
      %{
        "title" => book_data["title"],
        "author" => book_data["autors"],
        "isbn" => book_data["svītrkods"],
        "genres" => book_data["genres"],
        "publish_year" => String.to_integer(book_data["izdošanas_gads"]),
        "page_count" => String.to_integer(book_data["lappušu_skaits"]),
        "cover_image_url" => book_data["cover_image_url"],
        "anotation" => book_data["anotation"]
      }
    else
      %{
        "title" => book_data["title"],
        "author" => book_data["autor"],
        "isbn" => book_data["sku"],
        "genres" => book_data["genres"],
        "publish_year" => String.to_integer(book_data["publishing_year"]),
        "page_count" => String.to_integer(book_data["pages"]),
        "cover_image_url" => book_data["cover_image_url"],
        "anotation" => book_data["anotation"]
      }
    end
  end

  defp save_book_cover_image(url) do
    {:ok, response} = HTTPoison.get(url)

    filename = url |> URI.parse() |> Map.fetch!(:path) |> Path.basename()
    image_binary = response.body
    directory = "priv/static/images/covers"
    filepath = Path.join(directory, filename)

    File.mkdir_p(directory)
    File.write!(filepath, image_binary)
    {:ok, filename}
  end

  defp extract_generes(breadcrumbs) do
    breadcrumbs
    |> Meeseeks.all(css("li"))
    |> Enum.at(-2)
    |> Meeseeks.one(css("a"))
    |> Meeseeks.text()
    |> String.split(",")
    |> Enum.map(fn genre ->
      genre
      |> String.trim()
      |> String.downcase()
    end)
  end
end

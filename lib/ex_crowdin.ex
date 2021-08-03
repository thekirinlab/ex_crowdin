defmodule ExCrowdin do
  alias ExCrowdin.{Downloader, Uploader}

  def get_file_id(struct, field) do
    Uploader.get_file_id(struct, field)
  end

  def create_crowdin_file(struct) do
    Uploader.create_crowdin_file(struct)
  end

  def upload_one(struct, field, file_id) do
    Uploader.upload_one(struct, field, file_id)
  end

  def get_crowdin_translations(locale, field, file_id, page \\ 0) do
    Downloader.get_crowdin_translations(locale, field, file_id, page)
  end
end

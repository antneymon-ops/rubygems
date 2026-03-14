# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:documents) do
      primary_key :id
      String  :url,         null: false
      String  :title
      String  :status,      default: "pending"
      Integer :chunk_count, default: 0
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:chunks) do
      primary_key :id
      foreign_key :document_id, :documents, on_delete: :cascade
      Integer :position,    null: false
      String  :content,     text: true
      String  :embedding,   text: true  # JSON-serialized float array
      DateTime :created_at
    end

    create_table(:query_logs) do
      primary_key :id
      String  :query_text,   text: true, null: false
      String  :answer,       text: true
      String  :document_ids
      DateTime :created_at
    end
  end

  down do
    drop_table(:query_logs)
    drop_table(:chunks)
    drop_table(:documents)
  end
end

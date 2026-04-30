///|
/// Read top-level transitional wml.xsd element txbxContent as CT_TxbxContent (Part 4 §14).
pub fn read_txbx_content(bytes : Bytes) -> @domain.CT_TxbxContent raise {
  @domain.txbx_content(read_migration_root(bytes, "txbxContent"))
}

///|
fn read_migration_root(
  bytes : Bytes,
  local_name : String,
) -> @xml.Element raise {
  let root = @xml.parse(bytes).root
  if root.name.local_name != local_name {
    @domain.raise_schema_violation(
      "transitional wml.xsd top-level element",
      root.name.local_name,
      "expected " + local_name,
    )
  }
  root
}

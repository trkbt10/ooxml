///|
/// Write top-level transitional wml.xsd element txbxContent from CT_TxbxContent (Part 4 §14).
pub fn write_txbx_content(value : @domain.CT_TxbxContent) -> Bytes {
  write_element(value.element)
}

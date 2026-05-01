///|
/// §10.6 Relationships Transform Algorithm. Applies the OPC
/// relationships-transform rules to a relationships part before digest
/// computation. Currently raises UnsupportedFeature until signing support is
/// wired to the package layer.
pub fn apply_relationships_transform(
  source : Bytes,
) -> Bytes raise UnsupportedFeature {
  source |> ignore
  raise UnsupportedFeature(
    section="10.6",
    path="/",
    reason="relationships transform algorithm not implemented",
  )
}

///|
/// §10.8 Generating Signatures. Drives the signing process: collect
/// references, canonicalise SignedInfo, compute the signature value, and emit
/// the Signature element. Currently raises UnsupportedFeature until signing
/// support is wired to the package layer.
pub fn generate_signature(
  signed_info : SignedInfo,
) -> Signature raise UnsupportedFeature {
  signed_info |> ignore
  raise UnsupportedFeature(
    section="10.8",
    path="/Signature",
    reason="signature generation not implemented",
  )
}

///|
/// §10.9 Validating Signatures. Drives the validation process:
/// re-canonicalise SignedInfo, recompute the signature value, compare against
/// the embedded SignatureValue, and validate every Reference's digest.
/// Currently raises UnsupportedFeature.
pub fn validate_signature(
  signature : Signature,
) -> Bool raise UnsupportedFeature {
  signature |> ignore
  raise UnsupportedFeature(
    section="10.9",
    path="/Signature",
    reason="signature validation not implemented",
  )
}

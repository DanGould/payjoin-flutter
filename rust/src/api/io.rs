use crate::api::uri::{FfiOhttpKeys, FfiUrl};
use crate::utils::error::PayjoinError;

#[cfg(not(feature = "_danger-local-https"))]
/// Fetch the ohttp keys from the specified payjoin directory via proxy.
///
/// * `ohttp_relay`: The http CONNNECT method proxy to request the ohttp keys from a payjoin
/// directory.  Proxying requests for ohttp keys ensures a client IP address is never revealed to
/// the payjoin directory.
///
/// * `payjoin_directory`: The payjoin directory from which to fetch the ohttp keys.  This
/// directory stores and forwards payjoin client payloads.
pub async fn fetch_ohttp_keys(
    ohttp_relay: FfiUrl,
    payjoin_directory: FfiUrl,
) -> Result<FfiOhttpKeys, PayjoinError> {
    let res =
        payjoin_ffi::io::fetch_ohttp_keys((*ohttp_relay.0).clone(), (*payjoin_directory.0).clone());
    res.await.map(|e| e.into()).map_err(|e| e.into())
}

#[cfg(feature = "_danger-local-https")]
/// Fetch the ohttp keys from the specified payjoin directory via proxy.
///
/// * `ohttp_relay`: The http CONNNECT method proxy to request the ohttp keys from a payjoin
/// directory.  Proxying requests for ohttp keys ensures a client IP address is never revealed to
/// the payjoin directory.
///
/// * `payjoin_directory`: The payjoin directory from which to fetch the ohttp keys.  This
/// directory stores and forwards payjoin client payloads.
///
/// * `cert_der`: The DER-encoded certificate to use for local HTTPS connections.
pub async fn fetch_ohttp_keys(
    ohttp_relay: FfiUrl,
    payjoin_directory: FfiUrl,
    cert_der: Vec<u8>,
) -> Result<FfiOhttpKeys, PayjoinError> {
    let res = payjoin_ffi::io::fetch_ohttp_keys(
        (*ohttp_relay.0).clone(),
        (*payjoin_directory.0).clone(),
        cert_der,
    );
    res.await.map(|e| e.into()).map_err(|e| e.into())
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::api::uri::FfiUrl;
    #[tokio::test]
    async fn test_fetch_ohttp_keys() {
        let directory = FfiUrl::parse("https://payjo.in".to_string()).unwrap();
        let relay = FfiUrl::parse("https://pj.bobspacebkk.com".to_string()).unwrap();
        let _ = fetch_ohttp_keys(relay, directory).await;
    }
}

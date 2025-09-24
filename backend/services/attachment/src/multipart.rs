// use std::{pin::Pin, task::{Context, Poll}};

// use aws_sdk_s3::primitives::ByteStream;
// use aws_smithy_types::body::SdkBody;
// use axum::{
//     extract::{Multipart, multipart::Field}, response::IntoResponse
// };
// use bytes::Bytes;
// use futures_util::{AsyncRead, StreamExt, TryStreamExt, stream};
// use http_body::{Body, Frame, SizeHint};
// use tokio_util::io::StreamReader;
// use crate::ENV;

// async fn upload(mut multipart: Multipart, s3: aws_sdk_s3::Client) -> Result<String, String> 
// where 
//     Multipart : 'static
// {
//     if let Some(field) = multipart.next_field().await.unwrap() {
//         if field.name() == Some("file") {
//             let filename = field.file_name().unwrap_or("upload.bin").to_string();

//             let reader = field.map_err(|multipart_error| {
//                 std::io::Error::new(std::io::ErrorKind::Other, multipart_error)
//             });
            
//             let fb = FieldBody { inner: Box::pin(reader.into_async_read()) };
//             let body = SdkBody::from_body_1_x(fb);
//             let byte_stream = aws_sdk_s3::primitives::ByteStream::new(body);
//             let resp = s3.put_object()
//                 .bucket(&ENV.S3_BUCKET)
//                 .key(&filename)
//                 .body(byte_stream)
//                 .send()
//                 .await;

//             // if let Ok(resp) = resp {
//                 // return Ok(resp.e_tag.unwrap().to_string());
//             // }
//             todo!()
//         }
//     }

//     // "No file field found".to_string()
//     todo!()
// }


// pub struct FieldBody {
//     inner: Pin<Box<dyn AsyncRead + Send + Sync>>,
// }



// impl Body for FieldBody {
//     type Data = Bytes;
//     type Error = anyhow::Error;

//     fn poll_frame(
//         mut self: Pin<&mut Self>,
//         cx: &mut Context<'_>,
//     ) -> Poll<Option<Result<http_body::Frame<Self::Data>, Self::Error>>> {
//         let mut buf = [0u8; 8 * 1024]; // 8 KB buffer
//         let n = match Pin::new(&mut self.inner).poll_read(cx, &mut buf) {
//             Poll::Ready(Ok(n)) if n == 0 => return Poll::Ready(None),
//             Poll::Ready(Ok(n)) => n,
//             Poll::Ready(Err(e)) => return Poll::Ready(Some(Err(e.into()))),
//             Poll::Pending => return Poll::Pending,
//         };

//         Poll::Ready(Some(Ok(http_body::Frame::data(Bytes::copy_from_slice(&buf[..n])))))
//     }

//     fn is_end_stream(&self) -> bool {
//         false
//     }

//     fn size_hint(&self) -> http_body::SizeHint {
//         http_body::SizeHint::default()
//     }
// }

// // impl<'a> Body for FieldBody {
// //     type Data = Bytes;
// //     type Error = anyhow::Error;

// //     fn poll_frame(
// //         mut self: Pin<&mut Self>,
// //         cx: &mut Context<'_>,
// //     ) -> Poll<Option<Result<Frame<Self::Data>, Self::Error>>> {
// //         let fut = self.inner.next();
// //         tokio::pin!(fut);

// //         match fut.poll(cx) {
// //             Poll::Ready(Some(Ok(chunk))) => {
// //                 Poll::Ready(Some(Ok(Frame::data(chunk))))
// //             }
// //             Poll::Ready(Some(Err(e))) => {
// //                 Poll::Ready(Some(Err(anyhow::anyhow!(std::io::Error::new(std::io::ErrorKind::Other, e)))))
// //             }
// //             Poll::Ready(None) => Poll::Ready(None),
// //             Poll::Pending => Poll::Pending,
// //         }
// //     }

// //     fn is_end_stream(&self) -> bool {
// //         false
// //     }

// //     fn size_hint(&self) -> SizeHint {
// //         SizeHint::default()
// //     }
// // }

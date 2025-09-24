// use std::{pin::Pin, task::{Context, Poll}};

// use aws_sdk_s3::primitives::ByteStream;
// use aws_smithy_types::body::SdkBody;
// use axum::{
//     extract::{Multipart, multipart::Field}, response::IntoResponse
// };
// use bytes::Bytes;
// use futures_util::{StreamExt, TryStreamExt, stream};
// use http_body::{Body, Frame, SizeHint};
// use crate::ENV;

// async fn upload(mut multipart: Multipart, s3: aws_sdk_s3::Client) -> Result<String, String> {
//     while let Some(field) = multipart.next_field().await.unwrap() {
//         if field.name() == Some("file") {
//             let filename = field.file_name().unwrap_or("upload.bin").to_string();

//             // let stream = field.map(|result| {
//             //     result
//             //         .map_err(|e| std::io::Error::new(std::io::ErrorKind::Other, e))
//             // });

//             // let reader = tokio_util::io::StreamReader::new(field.map_err(|multipart_error| {
//             //     std::io::Error::new(std::io::ErrorKind::Other, multipart_error)
//             // }));
//             let body = SdkBody::from_body_1_x(field);
//             // let byte_stream = aws_sdk_s3::primitives::ByteStream::new(body);
//             // let resp = s3.put_object()
//                 // .bucket(&ENV.S3_BUCKET)
//                 // .key(&filename)
//                 // .body(byte_stream)
//                 // .send()
//                 // .await;

//             // if let Ok(resp) = resp {
//                 // return Ok(resp.e_tag.unwrap().to_string());
//             // }
//             todo!()
//         }
//     }

//     // "No file field found".to_string()
//     todo!()
// }






// // async fn bebra(b: Body, s3: aws_sdk_s3::Client) {
// //     let body = SdkBody::from_body_1_x(b);
// // }



// pub struct FieldBody<'a> {
//     field: Field<'a>,
// }

// impl<'a> Body for FieldBody<'a> {
//     type Data = Bytes;
//     type Error = anyhow::Error;

//     fn poll_data(
//         mut self: Pin<&mut Self>,
//         cx: &mut Context<'_>,
//     ) -> Poll<Option<Result<Frame<Self::Data>, Self::Error>>> {
//         let fut = self.field.next();
//         tokio::pin!(fut);

//         match fut.poll(cx) {
//             Poll::Ready(Some(Ok(chunk))) => {
//                 Poll::Ready(Some(Ok(Frame::data(chunk))))
//             }
//             Poll::Ready(Some(Err(e))) => {
//                 Poll::Ready(Some(Err(anyhow::anyhow!(std::io::Error::new(std::io::ErrorKind::Other, e)))))
//             }
//             Poll::Ready(None) => Poll::Ready(None),
//             Poll::Pending => Poll::Pending,
//         }
//     }

//     fn is_end_stream(&self) -> bool {
//         false // Field stream doesn’t provide exact end info synchronously
//     }

//     fn size_hint(&self) -> SizeHint {
//         SizeHint::default()
//     }
// }

using ZXing;
using ZXing.QrCode;
using UnityEngine;
using System.Collections;

namespace QRCode
{
    public static class QRCodeTools
    {
        #region 生成二维码
        public static Sprite createQRCode(string qrCodeStr)
        {
            Texture2D qrCodeTexture = new Texture2D(256, 256);

            var textForEncoding = qrCodeStr;
            if (textForEncoding != null)
            {
                var color32 = Encode(textForEncoding, qrCodeTexture.width, qrCodeTexture.height);
                qrCodeTexture.SetPixels32(color32);
                qrCodeTexture.Apply();
            }

            return Sprite.Create(qrCodeTexture, new Rect(0, 0, qrCodeTexture.width, qrCodeTexture.height), new Vector2(0.5f, 0.5f));
        }

        public static Color32[] Encode(string textForEncoding, int width, int height)
        {
            var writer = new BarcodeWriter
            {
                Format = BarcodeFormat.QR_CODE,
                Options = new QrCodeEncodingOptions
                {
                    Height = height,
                    Width = width,
                    Margin = 1
                }
            };
            return writer.Write(textForEncoding);
        }
        #endregion

        #region 识别二维码
        public static string DecodeQR(Color32[] data, int width, int height)
        {
            BarcodeReader br = new BarcodeReader();
            Result result = br.Decode(data, width, height);
            if (result != null)
            {
                return result.Text;
            }
            return string.Empty;
        }
        #endregion

    }
}

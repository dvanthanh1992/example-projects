import os

class Telegram_var:
    telegram_token = f"https://api.telegram.org/bot{os.environ.get('TELEGRAM_TOKEN')}"

class CameraURLs:
    def __init__(self):
        self.base_url = "http://giaothong.hochiminhcity.gov.vn/expandcameraplayer/"
        self.video_url_prefix = "videoUrl="
        self.camera_urls = {
            'tan_binh': [
                {
                    'camera_id': '58747923b807da0011e33cf5',
                    'camera_location': 'Nút giao Bảy Hiền 2 (Hoàng Văn Thụ)',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '662b5b481afb9c00172d92a8',
                    'camera_location': 'Trường Chinh - Trương Công Định',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '58df50ffdc195800111e04c0',
                    'camera_location': 'Cộng Hòa - Thăng Long',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ],
            'binh_thanh': [
                {
                    'camera_id': '5a606dbc8576340017d0662b',
                    'camera_location': 'Điện Biên Phủ - Nguyễn Hữu Cảnh',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '5d9ddec9766c880017188c9c',
                    'camera_location': 'Nút giao Hàng Xanh 5 (Hàng Xanh - Bạch Đằng)',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '5a8254b05058170011f6eac3',
                    'camera_location': 'Xô Viết Nghệ Tĩnh - Nguyễn Xí 1',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ],

            'quan_1': [
                {
                    'camera_id': '649da72ca6068200171a6dbb',
                    'camera_location': 'Tôn Đức Thắng - Hàm Nghi',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '5b632950fd4edb0019c7dc07',
                    'camera_location': 'Nguyễn Văn Cừ - Trần Hưng Đạo 3',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '5b0b7aba0e517b00119fd800',
                    'camera_location': 'Nguyễn Văn Cừ - Trần Hưng Đạo 1',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ],

            'quan_6': [
                {
                    'camera_id': '5d8cd372766c880017188940',
                    'camera_location': 'Nút giao Cây Gõ 2 (Minh Phụng)',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '5822f23aedeb6c0012a2d6a8',
                    'camera_location': 'Hồng Bàng - Nguyễn Thị Nhỏ',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '662b4f411afb9c00172d86fc',
                    'camera_location': 'Hậu Giang - Minh Phụng',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ],            

            'quan_9': [
                {
                    'camera_id': '56de42f611f398ec0c48127e',
                    'camera_location': 'Mai Chí Thọ - Võ Nguyên Giáp (Cát Lái cầu B)',
                    'video_url': 'http://camera.thongtingiaothong.vn/s/5874796db807da0011e33cf7/index.m3u8'
                },
                {
                    'camera_id': '63b54dcbbfd3d90017ea7ba8',
                    'camera_location': 'Quốc Lộ 1 - Cổng ĐH Quốc gia TPHCM',
                    'video_url': 'http://camera.thongtingiaothong.vn/s/59ca2cf302eb490011a0a3eb/index.m3u8'
                },
                {
                    'camera_id': '56df8159c062921100c143dc',
                    'camera_location': 'Nút giao Thủ Đức (Lê Văn Việt)',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ],

            'quan_12': [
                {
                    'camera_id': '5874796db807da0011e33cf7',
                    'camera_location': 'Trường Chinh - Tây Thạnh 1',
                    'video_url': 'http://camera.thongtingiaothong.vn/s/5874796db807da0011e33cf7/index.m3u8'
                },
                {
                    'camera_id': '59ca2cf302eb490011a0a3eb',
                    'camera_location': 'Cầu vượt An Sương 3',
                    'video_url': 'http://camera.thongtingiaothong.vn/s/59ca2cf302eb490011a0a3eb/index.m3u8'
                },
                {
                    'camera_id': '58d7c2e6c1e33c00112b321e',
                    'camera_location': 'Trường Chinh - Phan Văn Hớn 1 (Q12-HM)',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ],

            'go_vap': [
                {
                    'camera_id': '5a824f975058170011f6eab8',
                    'camera_location': 'Nguyễn Oanh - Phan Văn Trị (2)',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '59ca2cf302eb490011a0a3eb',
                    'camera_location': 'Phạm Văn Đồng - Phan Văn Trị 2',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
                {
                    'camera_id': '58d7c2e6c1e33c00112b321e',
                    'camera_location': 'Quang Trung - Tân Sơn',
                    'video_url': 'https://d2zihajmogu5jn.cloudfront.net/bipbop-advanced/bipbop_16x9_variant.m3u8'
                },
            ]
        }

    def get_urls_for_area(self, area):
        if area in self.camera_urls:
            camera_urls = []
            for camera_info in self.camera_urls[area]:
                camera_url = f"{self.base_url}?camId={camera_info['camera_id']}&camLocation={camera_info['camera_location']}&camMode=camera&{self.video_url_prefix}{camera_info['video_url']}"
                camera_urls.append(camera_url)
            return camera_urls
        return []



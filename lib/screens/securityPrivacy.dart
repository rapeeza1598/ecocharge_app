import 'package:flutter/material.dart';

class SecurityAndPrivacy extends StatelessWidget {
  const SecurityAndPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ข้อตกลงการใช้งาน'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '1. การยอมรับข้อตกลง',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'โดยการใช้งานแอปพลิเคชันนี้ เรียกใช้บริการ หรือทำธุรกรรมใดๆ ผู้ใช้ตกลงที่จะยอมรับข้อตกลงและเงื่อนไขการใช้งานต่อไปนี้ หากผู้ใช้ไม่ยอมรับข้อตกลงหรือเงื่อนไขการใช้งานดังกล่าว กรุณาเลิกใช้งานแอปพลิเคชันนี้ทันที',
            ),
            const SizedBox(height: 16.0),
            const Text(
              '2. บริการและการเข้าถึง',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'แอปพลิเคชันสถานีชาร์จรถยนต์ไฟฟ้ามีเป้าหมายในการให้บริการสำหรับผู้ใช้ที่ต้องการค้นหา และใช้งานสถานีชาร์จรถยนต์ไฟฟ้า ผู้ใช้ต้องรับผิดชอบต่อการเติมเครื่องชาร์จไฟฟ้า และค่าใช้จ่ายที่เกี่ยวข้องตามนโยบายของแต่ละสถานีชาร์จ',
            ),
            const SizedBox(height: 16.0),
            const Text(
              '3. ความรับผิดชอบ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'ผู้ใช้ตกลงที่จะใช้บริการแอปพลิเคชันและสถานีชาร์จรถยนต์ไฟฟ้าเป็นไปตามข้อตกลงนี้ และรับผิดชอบในการดำเนินการใดๆ ที่เกี่ยวข้องกับการใช้งานแอปพลิเคชันนี้',
            ),
            const SizedBox(height: 16.0),
            const Text(
              '4. ข้อมูลส่วนบุคคล',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'เราใช้ข้อมูลส่วนบุคคลของผู้ใช้เพื่อการทำงานและการพัฒนาแอปพลิเคชัน โดยเราจะปกป้องข้อมูลส่วนบุคคลตามนโยบายความเป็นส่วนตัวของเรา',
            ),
            const SizedBox(height: 16.0),
            const Text(
              '5. การเปลี่ยนแปลงข้อตกลง',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'เราอาจทำการปรับปรุงหรือเปลี่ยนแปลงข้อตกลงและเงื่อนไขการใช้งานได้โดยไม่ต้องแจ้งให้ทราบล่วงหน้า ดังนั้น ผู้ใช้ควรตรวจสอบข้อตกลงอย่างสม่ำเสมอ',
            ),
            const SizedBox(height: 16.0),
            const Text(
              '6. การติดต่อ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'หากมีข้อสงสัยหรือข้อร้องเรียนเกี่ยวกับการใช้งานแอปพลิเคชัน ผู้ใช้สามารถติดต่อเราผ่านช่องทางต่างๆ ที่ระบุไว้ในแอปพลิเคชัน',
            ),
            const SizedBox(height: 16.0),
            const Text(
              'โปรดทราบว่าการใช้งานแอปพลิเคชันนี้ถือว่าผู้ใช้ยอมรับข้อตกลงและเงื่อนไขการใช้งานทั้งหมดที่ระบุไว้ข้างต้น',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'ลายเซ็น: EchoCharge',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'วันที่: 25 เมษายน 2567',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('ยอมรับข้อตกลงและเงื่อนไข',
                        style: TextStyle(color: Colors.white))
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

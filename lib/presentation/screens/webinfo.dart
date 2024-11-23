import 'dart:convert';
import 'dart:io';
import 'package:flix/domain/device/device_profile_repo.dart';
import 'package:flix/domain/web_server.dart';
import 'package:flix/network/multicast_client_provider.dart';
import 'package:flix/presentation/screens/main_screen.dart';
import 'package:flix/presentation/style/colors/flix_color.dart';
import 'package:flix/presentation/widgets/segements/navigation_scaffold.dart';
import 'package:flix/theme/theme_extensions.dart';
import 'package:flix/utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';


class WebInfo extends StatefulWidget {
  @override
  bool showBack = true;
   WebInfo({super.key, required this.showBack});
  _WebInfoState createState() => _WebInfoState();
}

class _WebInfoState extends State<WebInfo> {


  @override
  void initState() {
    super.initState();
  }

  void clearThirdWidget() {
    Provider.of<BackProvider>(context, listen: false).backMethod();
  }

  String getPlatformIcon() {
    if (isMobile()) {
      return 'phone.webp';
    } else if (isDesktop()) {
      return 'pc.webp';
    } else {
      return 'pc.webp';
    }
  }
  
  @override
 Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
  var deviceName = DeviceProfileRepo.instance.deviceName;

    return NavigationScaffold(
      title: '网页版连接',
      onClearThirdWidget: clearThirdWidget,
      showBackButton: widget.showBack,
      builder: (EdgeInsets padding) {
        return Container(
          margin: const EdgeInsets.only( top: 6),
          width: double.infinity,
          child: SingleChildScrollView(  
            child: Column(
              children: [

                
             Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                  
                  Padding(
  padding: const EdgeInsets.all(16.0), // 设置四周的 padding
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 430), // 设置最大宽度为 500
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image(
          image: AssetImage('assets/images/${getPlatformIcon()}'),
          width: 36,
          height: 36,
          fit: BoxFit.fill,
        ),
        const SizedBox(width: 10),
        Text(
          '$deviceName（本机）',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).flixColors.text.primary,
          ),
        ),
      ],
    ),
  ),
),
  


               Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(

          child: Container(
            
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
              
          
                  //const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: QrImageView(
                      size: 150,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Theme.of(context).flixColors.text.primary,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Theme.of(context).flixColors.text.primary,
                      ),
                      data: 'http://${localIP!}:$port' ?? "error://no_pair_code",
                    
                    ),
                  ),
                  const SizedBox(height: 5),
                   Text(
                    '其他设备扫一扫，连接本设备',
                    style: TextStyle(fontSize: 16,color: Theme.of(context).flixColors.text.secondary),

                  ),
                    const SizedBox(height: 5),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        const SizedBox(height: 10),
               Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Center(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '网址连接',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            Text(
              '1. 在其他设备上，打开浏览器输入网址',
              style: TextStyle(
                color: Theme.of(context).flixColors.text.secondary,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            
            Text(
              '${localIP!}:$port' ,
              style: const TextStyle(
                color: FlixColor.blue,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '2.输入连接码',
              style: TextStyle(
                color: Theme.of(context).flixColors.text.secondary,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
           
            Text(
              randomNumber.toString(),
              style: const TextStyle(
                color: FlixColor.blue,
                fontSize: 20,
              ),
            ),
             ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        
                      ],
                    ),
                  ),
          ],
        ),
      ),
    ),
  ),
)
              ],
            ),
              ],
            ),
          ),
        );
      },
    );
  }
 
 

  

        

}

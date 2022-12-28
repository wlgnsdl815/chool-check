import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // latitude - 위도, longitude - 경도
  static final LatLng companyLatLng = LatLng(
    37.5233273,
    126.921252,
  ); // 여의도 wework의 위도와 경도

  static final CameraPosition initialPosition = CameraPosition(
    // 위에서 내려다 보는 카메라의 줌 레벨 정하기
    target: companyLatLng,
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder(
        future: checkPermission(),
        // checkPermission의 값이 바뀔때마다 builder를 재실행 시킨다
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // FutureBuilder 함수를 쓰면 future 파라미터에서 future를 리턴하는 함수를 불러올 수 있다
          // 또한 builder에서 snapshot으로 리턴값을 받을 수도 있다
          // 그래서 print(snapshot.data);를 하면 허가되었습니다. 라는 문구가 뜬다
          // print(snapshot.connectionState); connectionState는 future가 로딩중일때 waiting을 리턴, future를 받으면 done 리턴
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == '위치 권한이 허가 되었습니다.') {
            // checkPermission()에서 리턴해준 값이 snapshot.data에 들어간다. 위의 FutureBuilder()에서 작동한다
            return Column(
              children: [
                _CustomGoogleMap(
                  initialPosition: initialPosition,
                ),
                _ChoolCheckButton(),
              ],
            );
          }

          return Center(
            child: Text(snapshot.data),
          );
        },
      ),
    );
  }

  Future<String> checkPermission() async {
    // 권한을 받는 작업은 전부 async로 진행된다. 언제 유저가 권한을 줄 지 모르니까
    final isLocationEnabled =
        await Geolocator.isLocationServiceEnabled(); // 위치 권한에 대한 서비스

    if (!isLocationEnabled) {
      return '위치 서비스를 활성화 해주세요.';
    }

    LocationPermission checkedPermission = await Geolocator.checkPermission();

    if (checkedPermission == LocationPermission.denied) {
      // 권한이 denied 상태면(기본 값이 denied이다)
      checkedPermission =
          await Geolocator.requestPermission(); // 권한 요청하는 창을 띄운다

      if (checkedPermission == LocationPermission.denied) {
        // 근데도 계속 denied면, 위치 권한을 허가해달라는 문구를 리턴한다.
        return '위치 권한을 허가해주세요.';
      }
    }
    if (checkedPermission == LocationPermission.deniedForever) {
      return '앱의 위치 권한을 세팅에서 허가해주세요.';
    }

    return '위치 권한이 허가 되었습니다.'; // 위치 권한이 denied, deniedForever가 아니면 whileInUse, always인데 그렇다면 허가되었다는 문구 리턴
  }

  AppBar renderAppBar() {
    return AppBar(
      title: Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPosition;

  const _CustomGoogleMap({
    Key? key,
    required this.initialPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
      ),
    );
  }
}

class _ChoolCheckButton extends StatelessWidget {
  const _ChoolCheckButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text('출근'),
    );
  }
}

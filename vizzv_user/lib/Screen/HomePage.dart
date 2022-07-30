import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:eshop_multivendor/Helper/location_details.dart';
import 'package:eshop_multivendor/Screen/All_Category.dart';
import 'package:eshop_multivendor/Screen/live_track/update_screen.dart';
import 'package:eshop_multivendor/Screen/my_favorite_seller/category.dart';
import 'package:eshop_multivendor/Screen/new_search.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Model/UpdateUserLatLongModel.dart';
import 'package:eshop_multivendor/Helper/AppBtn.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/SimBtn.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/widget.dart';
import 'package:eshop_multivendor/Model/Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/CategoryProvider.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/NotificationLIst.dart';
import 'package:eshop_multivendor/Screen/SellerList.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:eshop_multivendor/Screen/free_food/free_seller_list.dart';
import 'package:eshop_multivendor/Screen/search_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import 'package:eshop_multivendor/Screen/Map.dart' as newMap;
import 'Login.dart';
import 'MyOrder.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'Search.dart';
import 'SectionList.dart';
var currentAddress = TextEditingController();
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
int count = 1;
List<Model> homeSliderList = [];
List<Widget> pages = [];

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {

  bool _isNetworkAvail = true;
  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Model> offerImages = [];
  List<String> bannerList = [
    "assets/images/banner0.png",
    "assets/images/banner1.png",
    "assets/images/banner2.png",
    "assets/images/banner3.png",
    "assets/images/banner4.png",
    "assets/images/banner5.png",
  ];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  var pinController = TextEditingController();
  Future<void> getCurrentLoc() async {
    GetLocation location = new GetLocation((result)async{
      if(mounted) {
        var loc = Provider.of<LocationProvider>(context, listen: false);
        if (currentAddress.text == "") {
          currentAddress.text = result.first.addressLine;
          latitude = result.first.coordinates.latitude;
          longitude = result.first.coordinates.longitude;
          pinController.text = result.first.postalCode;
          loc.lat = latitude;
          loc.lng = longitude;
          //changeLat2 = loc.lat;
          getSeller();
        }

        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString(mylatitude, latitude.toString());
        await preferences.setString(mylongitude, longitude.toString());
      }
    });
    location.getLoc();
    if (currentAddress.text != "") {
      getSeller();
    }
   /* Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var loc = Provider.of<LocationProvider>(context, listen: false);
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(mylatitude, latitude.toString());
    await preferences.setString(mylongitude, longitude.toString());
    List<Placemark> placemark = await placemarkFromCoordinates(
        double.parse(latitude!), double.parse(longitude!),
        localeIdentifier: "en");

    pinController.text = placemark[0].postalCode!;
    if (mounted) {
      setState(() {
        pinController.text = placemark[0].postalCode!;
        currentAddress.text =
            "${placemark[0].street}, ${placemark[0].subLocality} , ${placemark[0].locality}";
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        loc.lng = position.longitude.toString();
        loc.lat = position.latitude.toString();
        callApi();
      });
    }*/
  }

  var changeLat2;

  @override
  void initState() {

    super.initState();
    callApi();
    getCurrentLoc();

    WidgetsBinding.instance!.addPostFrameCallback((_) => _animateSlider());

  }
  bool shouldKeepAlive = true;
  @override
  bool get wantKeepAlive {
    print("changeLat2 :" + changeLat2.toString());
    print("new lat :" + latitude.toString());
    if(changeLat2.toString() == latitude.toString()){
      shouldKeepAlive = true;

    }else{
      if(changeLat2!=null){
        shouldKeepAlive = false;
      }
      changeLat2 = latitude.toString();

    }
    return shouldKeepAlive;
  }
  @override
  Widget build(BuildContext context) {
   super.build(context);
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(),
        leadingWidth: 0,
        backgroundColor: Colors.white,
        title: SizedBox(
          child: _deliverLocation(),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => NewSearch()));
              },
              icon: Icon(
                Icons.search,
                color: colors.primary,
              )),
          IconButton(
            icon: SvgPicture.asset(
              imagePath + "desel_notification.svg",
              color: colors.primary,
            ),
            onPressed: () {
              CUR_USERID != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationList(),
                      ))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
            },
          ),
          IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(
              Icons.shopping_bag_outlined,
              size: 24,
              color: colors.primary,
            ),
            onPressed: () {
              CUR_USERID != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOrder(),
                      ))
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
            },
          )
        ],
      ),
      body: _isNetworkAvail
          ? RefreshIndicator(
              color: colors.primary,
              key: _refreshIndicatorKey,
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _deliverLocation(),
                    _banner(),

                    _searchpage(),
                    _catList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _slider(),
                    ),
                    // _section(),
                    _seller(),
                    /*     CUR_USERID != null ? freeFood() : Container(),*/
                  ],
                ),
              ),
            )
          : noInternet(context),
    );
  }

  Future<Null> _refresh() async{
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);
     getSeller();
    return callApi();
  }

  _banner() {

   return CarouselSlider(
        items: bannerList.map((e) {
          return Image.asset(
            e,fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
          );
        }).toList(),
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height*0.3,
          initialPage: 0,
          viewportFraction: 1,
          enableInfiniteScroll: true,
          scrollPhysics: NeverScrollableScrollPhysics(),
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 3),
          autoPlayAnimationDuration: Duration(milliseconds: 200),
          autoPlayCurve: Curves.elasticInOut,
          scrollDirection: Axis.horizontal,
        )
    );

  }

  Widget _slider() {
    double height = deviceWidth! / 2.2;

    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? sliderLoading()
            : Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      Container(
                        height: height,
                        width: double.infinity,
                        // margin: EdgeInsetsDirectional.only(top: 10),
                        child: PageView.builder(
                          itemCount: homeSliderList.length,
                          scrollDirection: Axis.horizontal,
                          controller: _controller,
                          physics: AlwaysScrollableScrollPhysics(),
                          onPageChanged: (index) {
                            context.read<HomeProvider>().setCurSlider(index);
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return pages[index];
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        height: 40,
                        left: 0,
                        width: deviceWidth,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: map<Widget>(
                            homeSliderList,
                            (index, url) {
                              return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 2.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context
                                                .read<HomeProvider>()
                                                .curSlider ==
                                            index
                                        ? Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                        : Theme.of(context)
                                            .colorScheme
                                            .lightBlack,
                                  ));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 30)).then(
      (_) {
        if (mounted) {
          int nextPage = _controller.hasClients
              ? _controller.page!.round() + 1
              : _controller.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller.hasClients)
            _controller
                .animateToPage(nextPage,
                    duration: Duration(milliseconds: 200), curve: Curves.linear)
                .then((_) => _animateSlider());
        }
      },
    );
  }

  _singleSection(int index) {
    Color back;
    int pos = index % 5;
    if (pos == 0)
      back = Theme.of(context).colorScheme.back1;
    else if (pos == 1)
      back = Theme.of(context).colorScheme.back2;
    else if (pos == 2)
      back = Theme.of(context).colorScheme.back3;
    else if (pos == 3)
      back = Theme.of(context).colorScheme.back4;
    else
      back = Theme.of(context).colorScheme.back5;

    return sectionList[index].productList!.length > 0
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _getHeading(sectionList[index].title ?? "", index),
                    _getSection(index),
                  ],
                ),
              ),
              offerImages.length > index ? _getOfferImage(index) : Container(),
            ],
          )
        : Container();
  }

  _getHeading(String title, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: colors.yellow,
                ),
                padding: EdgeInsetsDirectional.only(
                    start: 10, bottom: 3, top: 3, end: 10),
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: colors.blackTemp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(sectionList[index].shortDesc ?? "",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize: Size.zero, // <
                    backgroundColor: (Theme.of(context).colorScheme.white),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                child: Text(
                  getTranslated(context, 'SHOP_NOW')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  SectionModel model = sectionList[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SectionList(
                        index: index,
                        section_model: model,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getOfferImage(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: FadeInImage(
            fadeInDuration: Duration(milliseconds: 150),
            image: CachedNetworkImageProvider(offerImages[index].image!),
            width: double.maxFinite,
            imageErrorBuilder: (context, error, stackTrace) => erroWidget(50),

            // errorWidget: (context, url, e) => placeHolder(50),
            placeholder: AssetImage(
              "assets/images/sliderph.png",
            )),
        onTap: () {
          if (offerImages[index].type == "products") {
            Product? item = offerImages[index].list;

            Navigator.push(
              context,
              PageRouteBuilder(
                  //transitionDuration: Duration(seconds: 1),
                  pageBuilder: (_, __, ___) =>
                      ProductDetail(model: item, secPos: 0, index: 0, list: true
                          //  title: sectionList[secPos].title,
                          )),
            );
          } else if (offerImages[index].type == "categories") {
            Product item = offerImages[index].list;
            if (item.subList == null || item.subList!.length == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    shop: false,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? Padding(
            padding: const EdgeInsets.all(15.0),
            child: GridView.count(
              // mainAxisSpacing: 12,
              // crossAxisSpacing: 12,
              padding: EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 0.750,

              //  childAspectRatio: 1.0,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                sectionList[i].productList!.length < 4
                    ? sectionList[i].productList!.length
                    : 4,
                (index) {
                  return productItem(i, index, index % 2 == 0 ? true : false);
                },
              ),
            ),
          )
        : sectionList[i].style == STYLE1
            ? sectionList[i].productList!.length > 0
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight! * 0.4
                                    : deviceHeight!,
                                child: productItem(i, 0, true))),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 1, false)),
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 2, false)),
                            ],
                          ),
                        ),
                      ],
                    ))
                : Container()
            : sectionList[i].style == STYLE2
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 0, true)),
                              Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: productItem(i, 1, true)),
                            ],
                          ),
                        ),
                        Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: Container(
                                height: orient == Orientation.portrait
                                    ? deviceHeight! * 0.4
                                    : deviceHeight,
                                child: productItem(i, 2, false))),
                      ],
                    ))
                : sectionList[i].style == STYLE3
                    ? Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                                flex: 1,
                                fit: FlexFit.loose,
                                child: Container(
                                    height: orient == Orientation.portrait
                                        ? deviceHeight! * 0.3
                                        : deviceHeight! * 0.6,
                                    child: productItem(i, 0, false))),
                            Container(
                              height: orient == Orientation.portrait
                                  ? deviceHeight! * 0.2
                                  : deviceHeight! * 0.5,
                              child: Row(
                                children: [
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 1, true)),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 2, true)),
                                  Flexible(
                                      flex: 1,
                                      fit: FlexFit.loose,
                                      child: productItem(i, 3, false)),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : sectionList[i].style == STYLE4
                        ? Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                    flex: 1,
                                    fit: FlexFit.loose,
                                    child: Container(
                                        height: orient == Orientation.portrait
                                            ? deviceHeight! * 0.25
                                            : deviceHeight! * 0.5,
                                        child: productItem(i, 0, false))),
                                Container(
                                  height: orient == Orientation.portrait
                                      ? deviceHeight! * 0.2
                                      : deviceHeight! * 0.5,
                                  child: Row(
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: productItem(i, 1, true)),
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.loose,
                                          child: productItem(i, 2, false)),
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        : Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: GridView.count(
                                padding: EdgeInsetsDirectional.only(top: 5),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.2,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 0,
                                children: List.generate(
                                  sectionList[i].productList!.length < 6
                                      ? sectionList[i].productList!.length
                                      : 6,
                                  (index) {
                                    return productItem(i, index,
                                        index % 2 == 0 ? true : false);
                                  },
                                )));
  }

  Widget productItem(int secPos, int index, bool pad) {
    if (sectionList[secPos].productList!.length > index) {
      String? offPer;
      double price = double.parse(
          sectionList[secPos].productList![index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(
            sectionList[secPos].productList![index].prVarientList![0].price!);
      } else {
        double off = double.parse(sectionList[secPos]
                .productList![index]
                .prVarientList![0]
                .price!) -
            price;
        offPer = ((off * 100) /
                double.parse(sectionList[secPos]
                    .productList![index]
                    .prVarientList![0]
                    .price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.5;

      return Card(
        elevation: 0.0,

        margin: EdgeInsetsDirectional.only(bottom: 2, end: 2),
        //end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag:
                              "${sectionList[secPos].productList![index].id}$secPos$index",
                          child: FadeInImage(
                            fadeInDuration: Duration(milliseconds: 150),
                            image: CachedNetworkImageProvider(
                                sectionList[secPos].productList![index].image!),
                            height: double.maxFinite,
                            width: double.maxFinite,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                erroWidget(double.maxFinite),
                            fit: BoxFit.cover,
                            placeholder: placeHolder(width),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 5.0,
                    top: 3,
                  ),
                  child: Text(
                    sectionList[secPos].productList![index].name!,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  " " + CUR_CURRENCY! + " " + price.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 5.0, bottom: 5, top: 3),
                  child: double.parse(sectionList[secPos]
                              .productList![index]
                              .prVarientList![0]
                              .disPrice!) !=
                          0
                      ? Row(
                          children: <Widget>[
                            Text(
                              double.parse(sectionList[secPos]
                                          .productList![index]
                                          .prVarientList![0]
                                          .disPrice!) !=
                                      0
                                  ? CUR_CURRENCY! +
                                      "" +
                                      sectionList[secPos]
                                          .productList![index]
                                          .prVarientList![0]
                                          .price!
                                  : "",
                              style: Theme.of(context)
                                  .textTheme
                                  .overline!
                                  .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                      letterSpacing: 0),
                            ),
                            Flexible(
                              child: Text(" | " + "-$offPer%",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                          color: colors.primary,
                                          letterSpacing: 0)),
                            ),
                          ],
                        )
                      : Container(
                          height: 5,
                        ),
                )
              ],
            ),
          ),
          onTap: () {
            Product model = sectionList[secPos].productList![index];
            Navigator.push(
              context,
              PageRouteBuilder(
                // transitionDuration: Duration(milliseconds: 150),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: model, secPos: secPos, index: index, list: false
                    //  title: sectionList[secPos].title,
                    ),
              ),
            );
          },
        ),
      );
    } else
      return Container();
  }

  _section() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                width: double.infinity,
                child: Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.simmerBase,
                  highlightColor: Theme.of(context).colorScheme.simmerHigh,
                  child: sectionLoading(),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: sectionList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  print("here");
                  return _singleSection(index);
                },
              );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }
    String catSel = "2";
  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Container(
                height: 120,
                padding: const EdgeInsets.only(top: 10, left: 10),
                child: ListView.builder(
                  itemCount: catList.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                   // print(catList[index].home_cat.toString());
                    return catList[index].home_cat.toString()=="1"?Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SellerList(
                                        catId: catList[index].id,
                                        catName: catList[index].name,
                                        subId: catList[index].subList,
                                        getByLocation: false,
                                      )));
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      bottom: 5.0),
                                  child: new ClipRRect(
                                    borderRadius: BorderRadius.circular(35.0),
                                      child: commonHWImage(catList[index].image.toString(),70.0,70.0,"",context,"assets/images/placeholder.png"),
                                     /* child: new FadeInImage(
                                      fadeInDuration: Duration(milliseconds: 150),
                                      image: CachedNetworkImageProvider(
                                        catList[index].image!,
                                      ),
                                      height: 70.0,
                                      width: 70.0,
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                          erroWidget(50),
                                      placeholder: placeHolder(50),
                                    ),*/
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    catList[index].name!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  // width: 50,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ):
                    Row(
                      children: [
                        SizedBox(),
                        index==catList.length-1?SizedBox(width: 5,):SizedBox(),
                        index==catList.length-1?InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Category(catList.toList())));
                            },
                            child: Text("View All",style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w700,color: Theme.of(context).colorScheme.fontColor),)):SizedBox(),
                      ],
                    );
                    if (index == 0)
                      return Container();
                    else
                      return catList[index].home_cat.toString()=="1"?Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SellerList(
                                              catId: catList[index].id,
                                              catName: catList[index].name,
                                              subId: catList[index].subList,
                                              getByLocation: false,
                                            )));
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        bottom: 5.0),
                                    child: new ClipRRect(
                                      borderRadius: BorderRadius.circular(35.0),
                                      child: new FadeInImage(
                                        fadeInDuration: Duration(milliseconds: 150),
                                        image: CachedNetworkImageProvider(
                                          catList[index].image!,
                                        ),
                                        height: 70.0,
                                        width: 70.0,
                                        fit: BoxFit.cover,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                erroWidget(50),
                                        placeholder: placeHolder(50),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      catList[index].name!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    // width: 50,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ):
                      Row(
                        children: [
                          SizedBox(),
                          index==catList.length-1?SizedBox(width: 5,):SizedBox(),
                          index==catList.length-1?InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Category(catList.toList())));
                              },
                              child: Text("View All",style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.w700,color: Theme.of(context).colorScheme.fontColor),)):SizedBox(),
                        ],
                      );
                  },
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<Null> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSetting();
      getSlider();
      getCat();
      //getSeller();
      // getSection();
      getOfferImages();
      // updateLatLong();
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    return null;
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        Map parameter = {
          USER_ID: CUR_USERID,
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();

            context.read<FavoriteProvider>().setFavlist(tempList);
          } else {
            if (msg != 'No Favourite(s) Product Are Added')
              setSnackbar(msg!, context);
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      } else {
        context.read<FavoriteProvider>().setLoading(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void getOfferImages() {
    Map parameter = Map();

    apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        offerImages.clear();
        offerImages =
            (data as List).map((data) => new Model.fromSlider(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setOfferLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setOfferLoading(false);
    });
  }

  void getSection() {
    print("section>>>>>>>>>>>>>>>>>>>>>>>>>");
    Map parameter = {PRODUCT_LIMIT: "6", PRODUCT_OFFSET: "10"};

    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    String curPin = context.read<UserProvider>().curPincode;
    if (curPin != '') parameter[ZIPCODE] = curPin;

    apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      sectionList.clear();
      if (!error) {
        var data = getdata["data"];

        sectionList = (data as List)
            .map((data) => new SectionModel.fromJson(data))
            .toList();
      } else {
        if (curPin != '') context.read<UserProvider>().setPincode('');
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    //print("")
    Map parameter = Map();
    if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

    apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
      bool error = getdata["error"];
      String? msg = getdata["message"];

      if (!error) {
        var data = getdata["data"]["system_settings"][0];
        cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
        refer = data["is_refer_earn_on"] == "1" ? true : false;
        // CUR_CURRENCY = data["currency"];
        CUR_CURRENCY = "₹";
        RETURN_DAYS = data['max_product_return_days'];
        MAX_ITEMS = data["max_items_cart"];
        MIN_AMT = data['min_amount'];
        CUR_DEL_CHR = data['delivery_charge'];
        String? isVerion = data['is_version_system_on'];
        extendImg = data["expand_product_images"] == "1" ? true : false;
        String? del = data["area_wise_delivery_charge"];
        MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];
        MAX_AMOUNT = data["cod_hide_max_amount"];
        GST_SERVICE_CHARGES = data["gst_service_charge"];
        if(data['is_under_construction'].toString()=="1"){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> UpdateScreen(data['under_construction_description'].toString())));
        }
        if(data['rain_status'].toString()=="1"){
          msgRain = data['rain_description'].toString();
          }
        if (del == "0")
          ISFLAT_DEL = true;
        else
          ISFLAT_DEL = false;

        if (CUR_USERID != null) {
          REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

          context
              .read<UserProvider>()
              .setPincode(getdata["data"]["user_data"][0][PINCODE]);

          if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty)
            generateReferral();

          context.read<UserProvider>().setCartCount(
              getdata["data"]["user_data"][0]["cart_total_items"].toString());
          context.read<UserProvider>().setBalance(
              getdata["data"]["user_data"][0]["balance"].toString());

          _getFav();
          _getCart("0");
        }

        UserProvider user = Provider.of<UserProvider>(context, listen: false);
        SettingProvider setting =
            Provider.of<SettingProvider>(context, listen: false);
        user.setMobile(setting.mobile);
        user.setName(setting.userName);
        user.setEmail(setting.email);
        user.setProfilePic(setting.profileUrl);

        Map<String, dynamic> tempData = getdata["data"];
        if (tempData.containsKey(TAG))
          tagList = List<String>.from(getdata["data"][TAG]);

        if (isVerion == "1") {
          String? verionAnd = data['current_version'];
          String? verionIOS = data['current_version_ios'];

          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String version = packageInfo.version;

          final Version currentVersion = Version.parse(version);
          final Version latestVersionAnd = Version.parse(verionAnd);
          final Version latestVersionIos = Version.parse(verionIOS);

          if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
              (Platform.isIOS && latestVersionIos > currentVersion))
            updateDailog();
        }
      } else {
        setSnackbar(msg!, context);
      }
    }, onError: (error) {
      setSnackbar(error.toString(), context);
    });
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();

    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save};

        Response response =
            await post(getCartApi, body: parameter, headers: headers)
                .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<SectionModel> cartList = (data as List)
              .map((data) => new SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setCartlist(cartList);
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<Null> generateReferral() async {
    String refer = getRandomString(8);
    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        REFER_CODE = refer;

        Map parameter = {
          USER_ID: CUR_USERID,
          REFERCODE: refer,
        };

        apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
      } else {
        if (count < 5) generateReferral();
        count++;
      }

      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        title: Text(getTranslated(context, 'UPDATE_APP')!),
        content: Text(
          getTranslated(context, 'UPDATE_AVAIL')!,
          style: Theme.of(this.context)
              .textTheme
              .subtitle1!
              .copyWith(color: Theme.of(context).colorScheme.fontColor),
        ),
        actions: <Widget>[
          new TextButton(
              child: Text(
                getTranslated(context, 'NO')!,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.lightBlack,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              }),
          new TextButton(
              child: Text(
                getTranslated(context, 'YES')!,
                style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                Navigator.of(context).pop(false);

                String _url = '';
                if (Platform.isAndroid) {
                  _url = androidLink + packageName;
                } else if (Platform.isIOS) {
                  _url = iosLink;
                }

                if (await canLaunch(_url)) {
                  await launch(_url);
                } else {
                  throw 'Could not launch $_url';
                }
              })
        ],
      );
    }));
  }

  Widget homeShimmer() {
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
          children: [
            catLoading(),
            sliderLoading(),
            sectionLoading(),
          ],
        )),
      ),
    );
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 0.5;
    return GestureDetector(
        child:commonHWImage(slider.image!, height, double.maxFinite, placeHolder, context, "assets/images/sliderph.png"),
    /*  child: FadeInImage(
          fadeInDuration: Duration(milliseconds: 150),
          image: CachedNetworkImageProvider(slider.image!),
          height: height,
          width: double.maxFinite,
          fit: BoxFit.fill,
          imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/sliderph.png",
                fit: BoxFit.fill,
                height: height,
                color: colors.primary,
              ),
          placeholderErrorBuilder: (context, error, stackTrace) => Image.asset(
                "assets/images/sliderph.png",
                fit: BoxFit.fill,
                height: height,
                color: colors.primary,
              ),
          placeholder: AssetImage(imagePath + "sliderph.png")),*/
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;
        print(homeSliderList[curSlider].type);
        if (homeSliderList[curSlider].type == "products") {
          print(homeSliderList[curSlider].list);
          if (homeSliderList[curSlider].list.length > 0) {
            Product item = homeSliderList[curSlider].list;
            Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ProductDetail(
                      model: item, secPos: 0, index: 0, list: true)),
            );
          }
        } else if (homeSliderList[curSlider].type == "categories") {
          var item = homeSliderList[curSlider].list;
          if (item.subList == null || item.subList!.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
            print("Product List");
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SellerList(
                          catId: item.categoryId,
                          catName: item.name,
                          getByLocation: true,
                        )));
            print("SellerList");
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.white,
                            shape: BoxShape.circle,
                          ),
                          width: 50.0,
                          height: 50.0,
                        ))
                    .toList()),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              context.read<HomeProvider>().setCatLoading(true);
              context.read<HomeProvider>().setSecLoading(true);
              context.read<HomeProvider>().setSliderLoading(true);
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  if (mounted)
                    setState(() {
                      _isNetworkAvail = true;
                    });
                  callApi();
                } else {
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  _deliverLocation() {
    var loc = Provider.of<LocationProvider>(context, listen: false);
    String curpin = context.read<UserProvider>().curPincode;
    return GestureDetector(
      child: Row(
        children: [
          Icon(
            Icons.location_pin,
            size: 18,
            color: colors.primary,
          ),
          Expanded(
            child: Text(
              currentAddress.text.isEmpty
                  ? getTranslated(context, 'SELOC')!
                  : getTranslated(context, 'DELIVERTO')! +
                  currentAddress.text,
              overflow: TextOverflow.fade,
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          )
        ],
      ),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlacePicker(
              apiKey: Platform.isAndroid
                  ? "AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY"
                  : "AIzaSyD6Jt-f1wlCIXV146XMOGtxrTNfzVB-2oY",
              onPlacePicked: (result) async{
                print(result.formattedAddress);
                currentAddress.text = result.formattedAddress.toString();
                latitude = result.geometry!.location.lat;
                longitude = result.geometry!.location.lng;
                SharedPreferences preferences = await SharedPreferences.getInstance();
                await preferences.setString(mylatitude, latitude.toString());
                await preferences.setString(mylongitude, longitude.toString());
               // pinController.text = result.first.postalCode;
                loc.lat = latitude;
                loc.lng = longitude;

                Navigator.of(context).pop();
                setState(() {
                  sellerList.clear();
                  getSeller();
                  _refresh();
                });
              },
              initialPosition: latitude!=null?LatLng(double.parse(latitude.toString()), double.parse(longitude.toString())):LatLng(20.5937,78.9629),
              useCurrentLocation: true,
            ),
          ),
        );
       /* var result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => newMap.Map(
                  latitude: latitude,
                  longitude: longitude,
                  from:
                  getTranslated(context, 'ADDADDRESS'),
                )));
        if(result!=null){

        }*/

      },
    );
  }

  _searchpage() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewSearch()));
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          dense: true,
          minLeadingWidth: 10,
          leading: Icon(
            Icons.search_rounded,
          ),
          title: Text(
            "Search For Products and More",
            style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ),
    );
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: ListView(shrinkWrap: true, children: [
                Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, bottom: 40, top: 30),
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Form(
                          key: _formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(Icons.close),
                                ),
                              ),
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: pinController,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) => validatePincode(val!,
                                    getTranslated(context, 'PIN_REQUIRED')),
                                onSaved: (String? value) {
                                  context
                                      .read<UserProvider>()
                                      .setPincode(value!);
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                decoration: InputDecoration(
                                  isDense: true,
                                  prefixIcon: Icon(Icons.location_on),
                                  hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      margin:
                                          EdgeInsetsDirectional.only(start: 20),
                                      width: deviceWidth! * 0.35,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          context
                                              .read<UserProvider>()
                                              .setPincode('');

                                          context
                                              .read<HomeProvider>()
                                              .setSecLoading(true);
                                          getSection();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                            getTranslated(context, 'All')!),
                                      ),
                                    ),
                                    Spacer(),
                                    SimBtn(
                                        size: 0.35,
                                        title: getTranslated(context, 'APPLY'),
                                        onBtnSelected: () async {
                                          if (validateAndSave()) {
                                            // validatePin(curPin);
                                            context
                                                .read<HomeProvider>()
                                                .setSecLoading(true);
                                            getSection();

                                            context
                                                .read<HomeProvider>()
                                                .setSellerLoading(true);
                                            getSeller();

                                            Navigator.pop(context);
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ))
              ]),
            );
            //});
          });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    Map map = Map();

    apiBaseHelper.postAPICall(getSliderApi, map).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        homeSliderList =
            (data as List).map((data) => new Model.fromSlider(data)).toList();

        pages = homeSliderList.map((slider) {
          return _buildImagePageItem(slider);
        }).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }

  void getCat() {
    Map parameter = {
      CAT_FILTER: "false",
    };
    apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList =
            (data as List).map((data) => new Product.fromCat(data)).toList();

        if (getdata.containsKey("popular_categories")) {
          var data = getdata["popular_categories"];
          popularList =
              (data as List).map((data) => new Product.fromCat(data)).toList();

          if (popularList.length > 0) {
            Product pop =
                new Product.popular("Popular", imagePath + "popular.svg");
            catList.insert(0, pop);
            context.read<CategoryProvider>().setSubList(popularList);
          }
        }
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  // Future<UpdateUserLatlongModel?> updateLatLong() async {
  //   var loc = Provider.of<LocationProvider>(context, listen: false);
  //
  //   var request = http.MultipartRequest('POST', updateUserLatLongApi);
  //   request.fields.addAll({
  //     'user_id': '$CUR_USERID',
  //     'latitude': '${loc.lat}',
  //     'longitude': '${loc.lng}'
  //   });
  //   request.headers.addAll(headers);
  //   http.StreamedResponse response = await request.send();
  //   if (response.statusCode == 200) {
  //     final str = await response.stream.bytesToString();
  //     return UpdateUserLatlongModel.fromJson(json.decode(str));
  //   }
  //   else {
  //   return null;
  //   }
  // }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 40),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: double.infinity,
                                height: 18.0,
                                color: Theme.of(context).colorScheme.white,
                              ),
                              GridView.count(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                childAspectRatio: 1.0,
                                physics: NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                children: List.generate(
                                  4,
                                  (index) {
                                    return Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color:
                                          Theme.of(context).colorScheme.white,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    sliderLoading()
                  ],
                ))
            .toList());
  }

  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    var loc = Provider.of<LocationProvider>(context, listen: false);

    Map parameter = {
      "lat": "${loc.lat}",
      "lang": "${loc.lng}",
      "shop_type": "3",
      // "veg_nonveg ": foodType ? "2" : "1",
    };
    print(parameter);
    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        dynamic data = getdata["data"];
        print("Get Seller Api data ==========================> : $data");
        print("Get Seller Parameter ==========================> : $parameter");
        if (data.isEmpty) {
          // showToast("No Seller Available");
        }
        sellerList =
            (data as List).map((data) {
              data['km']=calculateDistance(data['latitude'], data['longitude'], latitude, longitude);
              return new Product.fromSeller(data);}).toList();


        setState(() {
          sellerList.sort((a,b)=> a.km!.compareTo(b.km!));
          sellerList.sort((a,b)=> b.open_close_status!.compareTo(a.open_close_status!));
        });
      } else {
        // setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  _seller() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
                width: double.infinity,
                child: Shimmer.fromColors(
                    baseColor: Theme.of(context).colorScheme.simmerBase,
                    highlightColor: Theme.of(context).colorScheme.simmerHigh,
                    child: catLoading()))
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sellerList.isNotEmpty
                          ? ListTile(
                              title: Text(
                                  getTranslated(context, 'SHOP_BY_SELLER')!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                      fontWeight: FontWeight.bold)),
                            )
                          : Container(),
                      sellerList.isNotEmpty
                          ? ListView.builder(
                              itemCount: sellerList.length,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 1),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (sellerList[index].open_close_status ==
                                          "1") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SubCategory(
                                                      title: sellerList[index]
                                                          .store_name
                                                          .toString(),
                                                      sellerId:
                                                          sellerList[index]
                                                              .seller_id
                                                              .toString(),
                                                      sellerData:
                                                          sellerList[index],
                                                      shop: false,
                                                    )));
                                      } else {
                                        showToast("Shop Closed");
                                      }
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Card(
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 90,
                                                  width: 90,
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    child: commonImage(sellerList[index].seller_profile.toString(),"",context,"assets/images/placeholder.png"),
                                                   /* child: FadeInImage(
                                                      fadeInDuration: Duration(
                                                          milliseconds: 150),
                                                      image:
                                                          CachedNetworkImageProvider(
                                                        sellerList[index]
                                                            .seller_profile!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      imageErrorBuilder:
                                                          (context, error,
                                                                  stackTrace) =>
                                                              erroWidget(50),
                                                      placeholder:
                                                          placeHolder(50),
                                                    ),*/
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ListTile(
                                                        dense: true,
                                                        title: Text(
                                                            "${sellerList[index].store_name!}"),
                                                        subtitle:  Text(
                                                          "${sellerList[index].store_description!}",
                                                          maxLines: 2,
                                                        ),
                                                        trailing: Text(
                                                          sellerList[index]
                                                                      .open_close_status ==
                                                                  "1"
                                                              ? "Open"
                                                              : "Close",
                                                          style: TextStyle(
                                                              color: sellerList[
                                                                              index]
                                                                          .open_close_status ==
                                                                      "1"
                                                                  ? Colors.green
                                                                  : Colors.red),
                                                        ),
                                                      ),
                                                    /*  Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal:16.0),
                                                        child: Text(
                                                          "${sellerList[index].km!.toStringAsFixed(2)} km",
                                                          style: Theme.of(context).textTheme.caption!.copyWith(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .fontColor,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500,
                                                              fontSize:
                                                              10),
                                                        ),
                                                      ),*/
                                                      Divider(
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            FittedBox(
                                                              child: Row(
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .star_rounded,
                                                                    color: Colors
                                                                        .amber,
                                                                    size: 15,
                                                                  ),
                                                                  Text(
                                                                    "${sellerList[index].seller_rating!}",
                                                                    style: Theme.of(context).textTheme.caption!.copyWith(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .fontColor,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            sellerList[index]
                                                                        .estimated_time !=
                                                                    ""
                                                                ? FittedBox(
                                                                    child: Container(
                                                                        child: Center(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                2),
                                                                        child:
                                                                            Text(
                                                                          "${sellerList[index].estimated_time}",
                                                                          style:
                                                                              TextStyle(fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    )),
                                                                  )
                                                                : Container(),
                                                            sellerList[index]
                                                                        .food_person !=
                                                                    ""
                                                                ? FittedBox(
                                                                    child: Container(
                                                                        child: Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              5,
                                                                          vertical:
                                                                              1),
                                                                      child:
                                                                          Text(
                                                                        "${sellerList[index].food_person}",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14),
                                                                      ),
                                                                    )),
                                                                  )
                                                                : Container(),
                                                            Row(
                                                              children: [
                                                                sellerList[index]
                                                                    .veg_nonveg ==
                                                                    "3" ||
                                                                    sellerList[index]
                                                                        .veg_nonveg ==
                                                                        "1"
                                                                    ? Image.asset(
                                                                  "assets/images/veg.png",
                                                                  height: 20,
                                                                  width: 20,
                                                                )
                                                                    : SizedBox(),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                sellerList[index]
                                                                    .veg_nonveg ==
                                                                    "3" ||
                                                                    sellerList[index]
                                                                        .veg_nonveg ==
                                                                        "2"
                                                                    ? Image.asset(
                                                                  "assets/images/veg.png",
                                                                  height: 20,
                                                                  width: 20,
                                                                  color: Colors.red,
                                                                )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Image.asset(
                              "assets/images/shop_not_found.png",
                              scale: 5,
                            )),
                    ],
                  ),
                ),
              );
      },
      selector: (_, homeProvider) => homeProvider.sellerLoading,
    );
  }

  freeFood() {
    return InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FreeSellerLists()));
        },
        child: Image.asset('assets/images/free-food.jpg'));
  }
}

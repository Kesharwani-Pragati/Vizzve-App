
import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/Item_Search.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/ProductList.dart';
import 'package:eshop_multivendor/Screen/SellerRating.dart';
import 'package:eshop_multivendor/Screen/my_favorite_seller/add_remove_favrite_seller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/provider.dart';

class SellerProfile extends StatefulWidget {
  var sellerID,
      sellerName,
      sellerImage,
      sellerRating,
      storeDesc,
      sellerStoreName,
      subCatId;
  final sellerData;
  final search;
  final extraData;
  final coverImage;
  bool shop;
  SellerProfile(
      {Key? key,
      this.sellerID,
      this.sellerName,
      this.sellerImage,
      this.sellerRating,
      this.storeDesc,
      this.sellerStoreName,
      this.subCatId,
      this.sellerData,
      this.search,
      this.extraData,
      this.coverImage,required this.shop})
      : super(key: key);

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  late TabController _tabController;
  bool _isNetworkAvail = true;

  bool isDescriptionVisible = false;
  bool favoriteSeller = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var checkOut = Provider.of<UserProvider>(context);

    return Scaffold(
      // appBar: getAppBar("Store", context),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: colors.primary,
                  ),
                ),
              ),
            );
          },
        ),
        title: Text(
          "Store",
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
        actions: <Widget>[
          IconButton(
              icon: SvgPicture.asset(
                imagePath + "search.svg",
                height: 20,
                color: colors.primary,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemSearch(widget.sellerID, widget.sellerData.store_name),
                    ));
              }),
          "Store" == getTranslated(context, "FAVORITE")
              ? Container()
              : IconButton(
            padding: EdgeInsets.all(0),
            icon: SvgPicture.asset(
              imagePath + "desel_fav.svg",
              color: colors.primary,
            ),
            onPressed: () {
              CUR_USERID != null
                  ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Favorite(),
                ),
              )
                  : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ),
              );
            },
          ),
          Selector<UserProvider, String>(
            builder: (context, data, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    Center(
                        child: SvgPicture.asset(
                          imagePath + "appbarCart.svg",
                          color: colors.primary,
                        )),
                    (data != null && data.isNotEmpty && data != "0")
                        ? new Positioned(
                      bottom: 20,
                      right: 0,
                      child: Container(
                        //  height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: colors.primary),
                        child: new Center(
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: new Text(
                              data,
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.white),
                            ),
                          ),
                        ),
                      ),
                    )
                        : Container()
                  ],
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(
                        fromBottom: false,
                      ),
                    ),
                  )
                      : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                },
              );
            },
            selector: (_, homeProvider) => homeProvider.curCartCount,
          )
        ],
      ),
      bottomSheet: checkOut.curCartCount!=""&&checkOut.curCartCount!=null&&int.parse(checkOut.curCartCount) > 0
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(colors.primary)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Cart(fromBottom: false)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Check out",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(width: 0,),
      body: Material(
        child: Column(
          children: [
            widget.search
                ? Container()
                : Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        height: 200,
                        width: width * 1,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    widget.sellerData!.seller_profile),
                                fit: BoxFit.fill)),
                        child: Container(
                          height: height * 0.35,
                          width: width * 0.35,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                color: Colors.black.withOpacity(.5),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            widget.sellerData!.seller_profile),
                                      ),
                                      title: Text(
                                        "${widget.sellerData.store_name!}"
                                            .toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        "${widget.sellerData.store_description}",
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SellerRatingsPage(
                                                            sellerId:
                                                                widget.sellerID,
                                                          )));
                                            },
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: colors.primary,
                                                ),
                                                Text(
                                                  "${widget.sellerData.seller_rating}",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          widget.sellerData.estimated_time != ""
                                              ? Column(
                                                  children: [
                                                    Text(
                                                      "Delivery Time",
                                                      style: TextStyle(
                                                        color: colors.primary,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${widget.sellerData.estimated_time}",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                          widget.sellerData.food_person != ""
                                              ? Column(
                                                  children: [
                                                    Text(
                                                      "₹/Person",
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: colors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${widget.sellerData.food_person}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: AddRemveSeller(sellerID: widget.sellerID),
                        ),
                      ),
                      // SizedBox(height: MediaQuery.of(context).size.height*0.2),
                    ],
                  ),
            widget.search
                ? Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                    widget.sellerImage.toString()))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              color: Colors.black.withOpacity(.6),
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: CachedNetworkImageProvider(
                                          widget.sellerImage.toString()),
                                    ),
                                    title: Text(
                                      "${widget.sellerStoreName}".toUpperCase(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      "${widget.storeDesc}",
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: AddRemveSeller(sellerID: widget.sellerID),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Expanded(
              child: ProductList(
                fromSeller: true,
                name: "",
                id: widget.sellerID,
                subCatId: widget.subCatId,
                tag: false,
                status: widget.shop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget detailsScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: colors.primary,
              backgroundImage: NetworkImage(widget.sellerImage!),
            ),
          ),
          getHeading(widget.sellerStoreName!),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.sellerName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.lightBlack2, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: colors.primary),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.sellerRating!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: colors.primary),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.white,
                          size: 30,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isDescriptionVisible = !isDescriptionVisible;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'DESCRIPTION')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: colors.primary),
                          child: Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.white,
                            size: 30,
                          ),
                        ),
                        onTap: () => _tabController
                            .animateTo((_tabController.index + 1) % 2)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'PRODUCTS')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
              visible: isDescriptionVisible,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 8,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: colors.primary)),
                child: SingleChildScrollView(
                    child: Text(
                  (widget.storeDesc != "" || widget.storeDesc != null)
                      ? "${widget.storeDesc}"
                      : getTranslated(context, "NO_DESC")!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )),
              ))
        ],
      ),
    );
  }

  Widget getHeading(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.fontColor,
          ),
    );
  }

  Widget getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_outlined,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

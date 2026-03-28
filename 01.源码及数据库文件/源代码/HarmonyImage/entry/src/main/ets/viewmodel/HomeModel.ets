//轮播图的数据约束

export class SwiperDataModel{
  //id
  id:number = 0
  //商品
  productId:number = 0
  //图片url
  imageSrc: string = ''
  //跳转url
  navigatorUrl: string = ''
  //打开方式
  openType: string = ''
}

export class ActivityDataModel{
  //主键
  id:number = 0
  //活动图片的url
  imageSrc:string=''
  //活动名称
  name: string = ''
  //跳转的url
  navigatorUrl: string = ''
  //打开方式
  openType:string = ''
}

//商品的数据约束
export class ProductModel{
  //id
  id:number = 0
  //商品名称
  productName: string = ''
  //商品url
  productImageUrl: string = ''
  //商品的价格
  productPrice = ''
}
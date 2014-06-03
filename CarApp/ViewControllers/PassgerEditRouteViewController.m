//
//  PassgerEditRouteViewController.m
//  CarApp
//
//  Created by leno on 13-10-14.
//  Copyright (c) 2013年 Leno. All rights reserved.
//

#import "PassgerEditRouteViewController.h"
#import "GroupChatViewController.h"
#import "PassengerRoomCell.h"
#import "XmppManager.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "AddressImageViewController.h"
#import "AppUtility.h"
#import "Room.h"

#define kRoomPerPageNum 10

@interface PassgerEditRouteViewController ()

@property (strong, nonatomic) PullingRefreshTableView *tableView;
@property (strong, nonatomic) NSMutableArray *roomArray;
@property (strong, nonatomic) WarnView *warnView;
@property (strong, nonatomic) BMKMapView *mapView;

@property (strong, nonatomic) NSMutableArray *todayArray;
@property (strong, nonatomic) NSMutableArray *tomorrowArray;
@property (strong, nonatomic) NSMutableArray *afterTomorrowArray;
@property (strong, nonatomic) NSMutableArray *resultSortArray;
@property (assign, nonatomic) int sortCount;
//@property (assign, nonatomic) int mode; //1:正常 2:地图 3:图片

@end

@implementation PassgerEditRouteViewController

-(void)dealloc
{

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    [self.mapView setDelegate:self];
    [self performSelector:@selector(setMapAnonation) withObject:nil afterDelay:0.1];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    [self.mapView setDelegate:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tablerefreshing = NO;
    _canTableLoadMore = YES;
    _tablePage = 1;
    self.sortCount = 0;
//    _mode = 1;
    if(kDeviceVersion >= 7.0)
    {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    }
    _roomArray = [[NSMutableArray alloc]init];
    _todayArray = [[NSMutableArray alloc]init];
    _tomorrowArray = [[NSMutableArray alloc]init];
    _afterTomorrowArray = [[NSMutableArray alloc]init];
    _resultSortArray = [[NSMutableArray alloc]init];
    
    UIView * mainView = [[UIView alloc]initWithFrame:[AppUtility mainViewFrame]];
    [mainView setTag:10000];
    [mainView setBackgroundColor:[UIColor flatWhiteColor]];
    [self.view addSubview:mainView];
    
    UIImage * naviBarImage = [UIImage imageNamed:@"navgationbar_64"];
    naviBarImage = [naviBarImage stretchableImageWithLeftCapWidth:4 topCapHeight:10];
    
    UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    [navBar setTag:10005];
    [navBar setBackgroundImage:naviBarImage forBarMetrics:UIBarMetricsDefault];
    [mainView addSubview:navBar];
    
    if (kDeviceVersion < 7.0) {
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, navBar.frame.size.height, navBar.frame.size.width, 1)];
        [lineView setBackgroundColor:[UIColor lightGrayColor]];
        [navBar addSubview:lineView];
    }
    
    UIButton * backButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 20, 70, 44)];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_back_normal@2x"] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn_back_pressed@2x"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backToMain) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:backButton];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 20, 200, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:self.line.name];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor appNavTitleColor]];
    [titleLabel setFont:[UIFont fontWithName:kFangZhengFont size:18]];
    [navBar addSubview:titleLabel];
    
    UIImage * welcomeImage = [UIImage imageNamed:@"nav_hint@2x"];
    //    welcomeImage = [welcomeImage stretchableImageWithLeftCapWidth:8 topCapHeight:10];
    //导航栏下方的欢迎条
    UIImageView * welcomeImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, 320, 49)];
    [welcomeImgView setImage:welcomeImage];
    [mainView addSubview:welcomeImgView];
    
    UILabel * warnLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 300, 44)];
    [warnLabel setBackgroundColor:[UIColor clearColor]];
//    [warnLabel setText:@"为了您和司机的方便，请到标志物等候上车"];
    [warnLabel setText:[self.line.description stringByAppendingString:@"标志牌上车"]];
    [warnLabel setTextAlignment:NSTextAlignmentCenter];
    [warnLabel setTextColor:[UIColor whiteColor]];
    [warnLabel setFont:[UIFont appGreenWarnFont]];
    [welcomeImgView addSubview:warnLabel];
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
    
    UIImageView * photoImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 150)];
    [photoImgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    photoImgView.contentMode =  UIViewContentModeScaleAspectFill;
    [photoImgView setClipsToBounds:YES];
    [photoImgView setTag:60001];
    [photoImgView setImageWithURL:[NSURL URLWithString:self.line.img] placeholderImage:[UIImage imageNamed:@"delt_pic_b"]];
    [photoImgView setUserInteractionEnabled:YES];
    [photoImgView setBackgroundColor:[UIColor placeHoldColor]];
    [headView addSubview:photoImgView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAddressImageView)];
    [photoImgView addGestureRecognizer:tapGesture];

    
    BMKMapView *mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(12, 13+2, 106,106)];
    BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:BMKCoordinateRegionMake(mapView.userLocation.coordinate, BMKCoordinateSpanMake(0.02, 0.02))];
    [mapView setRegion:adjustedRegion animated:NO];
    [mapView.layer setCornerRadius:106/2.0];
    [mapView.layer setMasksToBounds:YES];
    [mapView setShowsUserLocation:NO];
    [mapView setOverlooking:0];
    [mapView setDelegate:self];
     self.mapView = mapView;
    //    [self.mapView setRotation:0];
    //    [self performSelector:@selector(setMapAnonation) withObject:nil afterDelay:0.2];
    [headView addSubview:mapView];
    
    UIButton *mapViewMask = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapViewMask setTag:10003];
    [mapViewMask setFrame:CGRectMake(10, 13, 110, 110)];
    [mapViewMask setBackgroundImage:[UIImage imageNamed:@"bg_map@2x"] forState:UIControlStateNormal];
    [mapViewMask addTarget:self action:@selector(maptapAction:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:mapViewMask];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 149.5, 320, 0.5)];
    [lineView setBackgroundColor:[UIColor appLineDarkGrayColor]];
    [headView addSubview:lineView];
    
    self.tableView = [[PullingRefreshTableView alloc]initWithFrame:CGRectMake(0, 64+44, 320, SCREEN_HEIGHT -64-44) pullingDelegate:self];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 2)];
    [self.tableView setTableFooterView:footerView];
    [mainView insertSubview:self.tableView belowSubview:navBar];
    [self.tableView setTableHeaderView:headView];
    
    self.warnView = [WarnView initWarnViewWithText:@"非常抱歉,暂无数据..." withView:self.tableView height:150+80 withDelegate:nil];
    
//    [self loadData:kRequestModeRefresh];
    
    
}

-(void)confirmmm
{
    GroupChatViewController * gVC = [[GroupChatViewController alloc]init];
    gVC.isRoomMaster = NO;
    [self.navigationController pushViewController:gVC animated:YES];
}

-(void)backToMain
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 数据交互
/*
//type 为 请求类型 mode为 请求方式 mode tag/judianID参数
-(void)loadData:(kRequestMode)mode{
    
    long uid = [User shareInstance].userId;
    //标签搜索
    [NetWorkManager networkGetRoomsWithuid:uid lineID:self.line.ID page:_tablePage rows:kRoomPerPageNum success:^(BOOL flag, BOOL hasnextpage, NSArray *roomArray, NSString *msg) {
        if (flag) {
            
            [self.roomArray removeAllObjects];
            [self.todayArray removeAllObjects];
            [self.tomorrowArray removeAllObjects];
            [self.afterTomorrowArray removeAllObjects];
            
            if (mode == kRequestModeRefresh) {
                [self.resultSortArray removeAllObjects];
            }
            
            _canTableLoadMore = hasnextpage;
            
            [self.roomArray addObjectsFromArray:roomArray];
            
            [self transformArray];
            
            [_tableView setReachedTheEnd:!hasnextpage];
            [_tableView setHeaderOnly:!hasnextpage];
            [_tableView tableViewDidFinishedLoading];
            [_tableView reloadData];
        }
        else
        {
            [_tableView tableViewDidFinishedLoading];
            [_tableView reloadData];
            [UIAlertView showAlertViewWithTitle:@"失败" message:msg cancelTitle:@"确定"];
        }
        
        if ([self.roomArray count]>0) {
            [self.warnView dismiss];
        }
        else
        {
            [self.warnView show:kenumWarnViewTypeNullData];
        }
        
        
    } failure:^(NSError *error) {
        
        //        [self.roomArray removeAllObjects];
        //        [_tableView setReachedTheEnd:YES];
        //        [_tableView setHeaderOnly:YES];
        [_tableView tableViewDidFinishedLoading];
        [_tableView reloadData];
        
    }];
    
    //    User *user = [User shareInstance];
    //
    //    //标签搜索
    //    [NetWorkManager networkGetRoomsWithID:user.userId page:_tablePage rows:kRoomPerPageNum success:^(BOOL flag, BOOL hasnextpage, NSArray *roomArray, NSString *msg) {
    //        if (flag) {
    //            _canTableLoadMore = hasnextpage;
    //            for(int i = 0; i < [roomArray count]; i++)
    //            {
    //                [self.roomArray addObject:[roomArray objectAtIndex:i]];
    //            }
    //            [self.tableView setReachedTheEnd:!hasnextpage];
    //            [self.tableView setHeaderOnly:!hasnextpage];
    //            [self.tableView tableViewDidFinishedLoading];
    //            [self.tableView reloadData];
    //        }
    //        else
    //        {
    //            [self.tableView tableViewDidFinishedLoading];
    //            [self.tableView reloadData];
    //            [UIAlertView showAlertViewWithTitle:@"失败" message:msg cancelTitle:@"确定"];
    //        }
    //
    //    } failure:^(NSError *error) {
    //
    //    }];
    
}
*/

-(void)transformArray
{
    for (Room *room in self.roomArray) {
        NSString *dayStr = [AppUtility dayStrTimeDate:room.start_time];
        
        if ([dayStr isEqualToString:@"今天"]) {
            [self.todayArray addObject:room];
        }
        
        if ([dayStr isEqualToString:@"明天"]) {
            [self.tomorrowArray addObject:room];
        }
        
        if ([dayStr isEqualToString:@"后天"]) {
            [self.afterTomorrowArray addObject:room];
        }
        
        if ([dayStr isEqualToString:@"未知"]) {
            
        }
    }
    
    if ([self.todayArray count] > 0) {
        NSDictionary *toddic = [NSDictionary dictionaryWithObject:self.todayArray forKey:@"today"];
        [self.resultSortArray  addObject:toddic];
    }
    
    if ([self.tomorrowArray count] > 0) {
        NSDictionary *tomdic = [NSDictionary dictionaryWithObject:self.tomorrowArray forKey:@"tomorrow"];
        [self.resultSortArray  addObject:tomdic];
    }
    
    if ([self.afterTomorrowArray count] > 0) {
        NSDictionary *aftmdic = [NSDictionary dictionaryWithObject:self.afterTomorrowArray  forKey:@"afterTomorrow"];
        [self.resultSortArray addObject:aftmdic];
    }
}

#pragma mark - mapImageHeadViewDelegate
-(void)setMapAnonation
{
    [_mapView removeAnnotations:_mapView.annotations];
    BMKPointAnnotation* addPoint = [[BMKPointAnnotation alloc]init];
    [addPoint setTitle:self.line.startaddr];
    [addPoint setCoordinate:CLLocationCoordinate2DMake(self.line.startlatitude, self.line.startlongitude)];
    [_mapView addAnnotation:addPoint];
}

-(void)maptapAction:(UIButton *)sender
{
    MapViewController *mapVC =  [[MapViewController alloc]init];
    mapVC.line = self.line;
    mapVC.mode = kMapViewModeLine;
    [mapVC setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self.navigationController pushViewController:mapVC animated:YES];
//    if (self.mode != 2) {
//        [self showMapView:YES];
//    }
//    else
//    {
//        [self showMapView:NO];
//    }
}

//显示图片
-(void)showAddressImageView
{
    AddressImageViewController *addressImageViewController = [[AddressImageViewController alloc]init];
    addressImageViewController.line = self.line;
    [addressImageViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:addressImageViewController animated:YES completion:^{}];

}

#pragma mark - bmkMapViewDelegate methods
-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [self.mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}


-(void)mapView:(BMKMapView *)mapView didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:BMKCoordinateRegionMake(self.mapView.userLocation.coordinate, BMKCoordinateSpanMake(0.02, 0.02))];
    [self.mapView setRegion:adjustedRegion animated:NO];
    //       self.locateSuccess = YES;
    //       self.location = userLocation.location.coordinate;
    //       self.locateState = NO;
    //       [self.search reverseGeocode:self.mapView.userLocation.location.coordinate];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:NO];
}

-(void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapview viewForAnnotation:(id <BMKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
		BMKAnnotationView* view = nil;
        view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_nodeAddress"];
        if (view == nil) {
            view = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"start_nodeAddress"];
            view.image = [UIImage imageNamed:@"tag_map@2x"];
            view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.0));
            view.canShowCallout = TRUE;
        }
        view.annotation = annotation;
        BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:BMKCoordinateRegionMake(annotation.coordinate, BMKCoordinateSpanMake(0.01, 0.01))];
        [self.mapView setRegion:adjustedRegion animated:NO];
        [self.mapView setCenterCoordinate:annotation.coordinate animated:NO];
        return view;
	}
	return nil;
}

#pragma mark - Refresh and load more methods

- (void) refreshTable
{
    /*
     Code to actually refresh goes here.
     */
    //对tableModel进行判断
    _tablePage = 1;
    _sortCount = 0;
    
//    [self loadData:kRequestModeRefresh];
}

- (void) loadMoreDataToTable
{
    /*
     Code to actually load more data goes here
     */
    //对tableModel进行判断
    if (_canTableLoadMore) {
        _tablePage ++;
//        [self loadData:kRequestModeLoadmore];
    }
}

#pragma mark - PullingRefreshTableViewDelegate
- (void)pullingTableViewDidStartRefreshing:(PullingRefreshTableView *)tableView{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.f];
}

- (void)pullingTableViewDidStartLoading:(PullingRefreshTableView *)tableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:0.f];
}

#pragma mark - tableViewDelegate/tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int sectionNum = [self.resultSortArray count];
    return sectionNum;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
    [label setBackgroundColor:UIColorFromRGB(0xF3F3F3)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:UIColorFromRGB(0x333333)];
    [label setFont:[UIFont fontWithName:kFangZhengFont size:10]];
    
    NSString *key = [[((NSDictionary *)[self.resultSortArray objectAtIndex:section])allKeys]objectAtIndex:0];
    if ([key isEqualToString:@"today"]) {
        [label setText:@"今天"];
    }
    if ([key isEqualToString:@"tomorrow"]) {
        [label setText:@"明天"];
    }
    if ([key isEqualToString:@"afterTomorrow"]) {
        [label setText:@"后天"];
    }
    
    return label;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = (NSArray *)[[((NSDictionary *)[self.resultSortArray objectAtIndex:section])allValues]objectAtIndex:0];
    int num = [array count];
    return num;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"_RoomTableCell";
    PassengerRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[PassengerRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    if (kDeviceVersion >= 7.0) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    NSArray *array = (NSArray *)[[((NSDictionary *)[self.resultSortArray objectAtIndex:indexPath.section])allValues]objectAtIndex:0];
    Room *room = [array objectAtIndex:indexPath.row];
    
    //[cell.imagerView setImageWithURL:[NSURL URLWithString:room.headpic] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"delt_user_s"]];
    [cell.imagerView setTag:1000+indexPath.row];
    [cell.imagerView addTarget:self action:@selector(headImageTapAction:) forControlEvents:UIControlEventTouchDown];
    [cell setBackgroundColor:[UIColor whiteColor]];
   // [cell.nameLable setText:room.username];
    
    NSString *mmssTime = [AppUtility strFromDate:room.start_time withFormate:@"HH:mm"];
//    NSString *dayTime = [AppUtility dayStrTimeDate:room.startingtime];
//    [cell.dayLable setText:dayTime];
    [cell.timeLable setText:mmssTime];
    if (self.sortCount < 3) {
        [cell.timeLable setTextColor:[UIColor appTimerColor:self.sortCount++]];
    }
    else
    {
        [cell.timeLable setTextColor:[UIColor appTimerColor:kTimerColorDep3]];
    }
    
    [cell.desLable setText:[room.description isEqualToString:@""]?@"暂无":room.description];
    [cell.lastSeatLable setText:[NSString stringWithFormat:@"%d",room.max_seat_num-room.booked_seat_num]];
    
     NSString * publishTime =  [AppUtility strTimeInterval:[[NSDate date] timeIntervalSinceDate:room.start_time]];
    [cell.pubTimeLable setText:[NSString stringWithFormat:@"%@发布",publishTime]];
     
    
//    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *array = (NSArray *)[[((NSDictionary *)[self.resultSortArray objectAtIndex:indexPath.section])allValues]objectAtIndex:0];
    Room *room = [array objectAtIndex:indexPath.row];
    
//    //进入房间
//    [[XmppManager sharedInstance] createGroup:[NSString stringWithFormat:@"%ld",room.ID]];
    
    //创建成功进入聊天室
    GroupChatViewController * gVC = [[GroupChatViewController alloc]init];
    gVC.roomID = room.ID;
    gVC.isRoomMaster = NO;
    gVC.userState = 1;
    [self.navigationController pushViewController:gVC animated:YES];
}

#pragma mark - 头像点击
-(void)headImageTapAction:(UIButton *)sender
{
    DLog(@"头像点击");
    int index = sender.tag - 1000;
    Room *room = (Room *)[self.roomArray objectAtIndex:index];
    ProfileViewController * profileVC = [[ProfileViewController alloc]init];
    profileVC.uid = room.user_id;
    profileVC.state = 1;
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end

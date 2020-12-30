//
//  ZZAutomateFloatVC.m
//  ZZProjectOC
//
//  Created by 刘猛 on 2019/1/10.
//  Copyright © 2019 刘猛. All rights reserved.
//

#import "ZZTools.h"
#import "ZZAutomateFloatVC.h"
#import <MJRefresh/MJRefresh.h>
#import "ZZCollectionViewCell.h"
#import "ZZCollectionHeaderView.h"

@interface ZZAutomateFloatVC ()<UICollectionViewDelegate, UICollectionViewDataSource, ZZLayoutDelegate>

/**页面主视图*/
@property (nonatomic , strong) UICollectionView *collectionView;

/**数据数组*/
@property (nonatomic , strong) NSMutableArray   *modelArrays;

@end

@implementation ZZAutomateFloatVC

+ (void)load {
    [[ZZRouter shared] mapRoute:@"app/demo/automateFloat" toControllerClass:[self class]];//浮动瀑布流
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"浮动";
    [self.view addSubview:self.collectionView];
}

#pragma mark- 协议方法
//collectionView的协议方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击了第: %ld个区的第: %ld个item", indexPath.section,indexPath.row);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZZCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZZCollectionViewCell" forIndexPath:indexPath];
    ZZModel *model = self.modelArrays[indexPath.section][indexPath.row];
    cell.backgroundColor = model.color;
    cell.title = [NSString stringWithFormat:@"第%ld个", indexPath.row];
    return cell;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *arr = self.modelArrays[section];
    return arr.count;
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.modelArrays.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    // 区头
    if (kind == UICollectionElementKindSectionHeader) {
        ZZCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZZCollectionHeaderView" forIndexPath:indexPath];
        headerView.label.text = [NSString stringWithFormat:@"这里是第: %ld个区的区头",indexPath.section];
        reusableView = headerView;
    }
    // 区尾
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionElementKindSectionFooter" forIndexPath:indexPath];
        reusableView = footerView;
    }
    return reusableView;
}

//ZZLyout的流协议方法
- (CGFloat)layout:(ZZLayout *)layout heightForRowAtIndexPath:(NSIndexPath *)indexPath {//返回item的度
    return indexPath.section % 2 == 0 ? 25 : 30;//同一section下请不要改变高度.
}

- (CGFloat)layout:(ZZLayout *)layout widthForRowAtIndexPath:(NSIndexPath *)indexPath {//返回item的宽
    ZZModel *model = self.modelArrays[indexPath.section][indexPath.row];
    return model.width;//这里可以根据内容传入任意宽度
}

- (UIEdgeInsets)layout:(ZZLayout *)layout insetForSectionAtIndex:(NSInteger)section {//设置每个区的边距
    return UIEdgeInsetsMake(10, 0, 10, 50);
}

- (NSInteger)layout:(ZZLayout *)layout lineSpacingForSectionAtIndex:(NSInteger)section {//设置每个区的行间距
    return 10;
}

- (CGFloat) layout:(ZZLayout *)layout interitemSpacingForSectionAtIndex:(NSInteger)section {//设置每个区的列间距
    return 15;
}

- (CGSize)layout:(ZZLayout *)layout referenceSizeForHeaderInSection:(NSInteger)section {//设置区头的高度
    return CGSizeMake(self.view.bounds.size.width, 44);
}

- (UIColor *)layout:(UICollectionView *)layout colorForSection:(NSInteger)section {
    if (section == 1) {
        return [UIColor redColor];
    }
    return [UIColor darkGrayColor];
}

#pragma mark- 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        ZZLayout *layout = [[ZZLayout alloc] initWith:ZZLayoutFlowTypeAutomateFloat delegate:self];
        //layout.sectionHeadersPinToVisibleBounds = YES;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64 - ([UIScreen mainScreen].bounds.size.height >= 812.f ? 24 : 0)) collectionViewLayout:layout];
        _collectionView.delegate = self;_collectionView.dataSource = self;
        
        //实现"头视图"效果
        UILabel *headerView = [[UILabel alloc] init];
        headerView.frame = CGRectMake(0, -200, self.view.bounds.size.width, 200);
        headerView.backgroundColor = [UIColor whiteColor];
        headerView.text = @"实现类似tableView的头视图效果.";
        headerView.textColor = [UIColor blackColor];
        headerView.backgroundColor = [UIColor redColor];
        headerView.textAlignment = NSTextAlignmentCenter;
        [_collectionView addSubview:headerView];
        _collectionView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
        
        //配合MJRefresh可这么使用.
        __weak typeof(self)weakSelf = self;
        MJRefreshNormalHeader *header =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.modelArrays = nil;
                [weakSelf.collectionView.mj_header endRefreshing];
                [weakSelf.collectionView reloadData];
            });
        }];
        
        header.ignoredScrollViewContentInsetTop = 200;
        _collectionView.mj_header = header;
        
        //注册cell
        [_collectionView registerClass:[ZZCollectionViewCell class] forCellWithReuseIdentifier:@"ZZCollectionViewCell"];
        [_collectionView registerClass:[ZZCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ZZCollectionHeaderView"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionElementKindSectionFooter"];
        
        //_collectionView.contentInset = UIEdgeInsetsMake(AfW(319), 0, 0, 0);
        _collectionView.showsHorizontalScrollIndicator = NO;_collectionView.bounces = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        if (@available(iOS 11.0, *)) {_collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;}
        _collectionView.backgroundColor = [UIColor whiteColor];
        
    }
    return _collectionView;
}

- (NSMutableArray *)modelArrays {
    if (!_modelArrays) {
        _modelArrays = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i ++) {
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            int count = rand() % 31 + 20;
            for (int j = 0; j < count; j ++) {
                ZZModel *model = [[ZZModel alloc] init];
                model.width = rand() % 100 + 80;
                model.color = [UIColor colorWithRed:(rand() % 255) / 255.0 green:(rand() % 255) / 255.0 blue:(rand() % 255) / 255.0 alpha:1];
                [array addObject:model];
            }
            [_modelArrays addObject:array];
            
        }
    }
    return _modelArrays;
}

@end

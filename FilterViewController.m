//
//  FilterViewController.m
//  PhillipFashionProject
//
//  Created by Phillip Ou on 10/28/14.
//  Copyright (c) 2014 Phillip Ou. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController{
    NSMutableArray *firstSectionCellsArray;
    NSMutableArray *secondSectionCellsArray;
    NSString *searchTemplate;
    NSMutableArray *categoryStringArray;
    NSMutableArray *priceStringArray;
    NSString *categoryString;
    NSString *priceString;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    firstSectionCellsArray = [[NSMutableArray alloc]init];
    secondSectionCellsArray = [[NSMutableArray alloc]init];
    categoryStringArray=[[NSMutableArray alloc]init];
    priceStringArray =[[NSMutableArray alloc]init];
    searchTemplate=@"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=%@&%@&count=1000";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section==0){
        return 2;
    }
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Return the title of each section
    if(section==1){
        return @"Category";
    }
    else{
        return @"Price";
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSInteger rowNumber = 0;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    rowNumber += indexPath.row;
    
    
    switch(rowNumber){
        case 0:
            cell.textLabel.text = @"Men";
            break;
        case 1:
            cell.textLabel.text = @"Women";
            break;
        case 2:
            cell.textLabel.text = @"$";
            break;
        case 3:
            cell.textLabel.text = @"$$";
            break;
        case 4:
            cell.textLabel.text = @"$$$";
            break;
       
       
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSNumber *rowNumber = [NSNumber numberWithUnsignedInt:indexPath.row];
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        if (selectedCell.accessoryType == UITableViewCellAccessoryNone)
        {
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
         
                [firstSectionCellsArray addObject:rowNumber];
                [categoryStringArray addObject:selectedCell.textLabel.text ];
            
        }
        else if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
          
                
                [firstSectionCellsArray removeObject:rowNumber];
                [categoryStringArray removeObject:selectedCell.textLabel.text ];

            selectedCell.accessoryType = UITableViewCellAccessoryNone;
        }
        NSLog(@"category:%@",categoryStringArray);
        
        if([categoryStringArray count]==1){
            categoryString=[categoryStringArray firstObject];
        }
        else{
            categoryString=@"";
        }
    }
    
    if (indexPath.section == 1)
    {
        NSNumber *rowNumber = [NSNumber numberWithUnsignedInt:indexPath.row];
        
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        if (selectedCell.accessoryType == UITableViewCellAccessoryNone)
        {
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            [secondSectionCellsArray addObject:rowNumber];
            switch(indexPath.row){
                case 0:
                    [priceStringArray addObject:@"fl=p20"];
                    break;
                case 1:
                    [priceStringArray addObject:@"fl=p50"];
                    break;
                case 2:
                    [priceStringArray addObject:@"fl=p100"];
                    break;
            }
            
        }
        else if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
           
            [secondSectionCellsArray removeObject:rowNumber];
            switch(indexPath.row){
                case 0:
                    [priceStringArray removeObject:@"fl=p20"];
                    break;
                case 1:
                    [priceStringArray removeObject:@"fl=p50"];
                    break;
                case 2:
                    [priceStringArray removeObject:@"fl=p100"];
                    break;
              
            }
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
            
        }
        NSLog(@"prices:%@",priceStringArray);
        priceString=@"";
        for(int i=0; i< [priceStringArray count]; i++){
             NSLog(@"%@", [priceStringArray objectAtIndex:i]);
            priceString = [priceString stringByAppendingFormat:@"%@ ",[priceStringArray objectAtIndex:i]];
        }
         priceString =[priceString stringByReplacingOccurrencesOfString:@" " withString:@"&"];
         NSLog(@"%@",priceString);
    }
    if(!priceString){
        priceString=@"";
    }
    if(!categoryString){
        categoryString=@"";
    }
    searchTemplate = [NSString stringWithFormat:@"http://api.shopstyle.com/action/apiSearch?pid=uid1361-25624519-1&format=json&fts=Tops+%@&%@&count=250",categoryString,priceString];
    NSLog(@"%@",searchTemplate);
    
}


- (IBAction)setFilter:(id)sender {
    
    [self.delegate updateSearch:searchTemplate forFilter:categoryString:priceString];
    
}

@end

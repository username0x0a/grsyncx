//
//  WindowActionsResponder.h
//  grsyncx
//
//  Created by Michal Zelinka on 13/01/2020.
//  Copyright © 2020 Michal Zelinka. All rights reserved.
//

#ifndef WindowActionsResponder_h
#define WindowActionsResponder_h

@protocol WindowActionsResponder <NSObject>

@required
- (void)didReceiveAddProfileAction;
- (void)didReceiveDeleteProfileAction;
- (void)didReceiveSimulateAction;
- (void)didReceiveExecuteAction;

@end

#endif /* WindowActionsResponder_h */

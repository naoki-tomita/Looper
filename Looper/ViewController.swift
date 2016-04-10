//
//  ViewController.swift
//  Looper
//
//  Created by 冨田 直希 on 2016/04/09.
//  Copyright © 2016年 冨田 直希. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let btPlay: UIButton = UIButton();
  var playing = false;
  let looper: LooperModel = LooperModel();

  override func viewDidLoad() {
    super.viewDidLoad()

    // 再生ボタン
    btPlay.setTitle("PLAY", forState: UIControlState.Normal);
    btPlay.setTitle("PLAY", forState: UIControlState.Highlighted);
    btPlay.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal);
    btPlay.setTitleColor(UIColor.lightGrayColor() , forState: UIControlState.Highlighted);
    btPlay.addTarget(self, action: "onClickedPlay:", forControlEvents: UIControlEvents.TouchUpInside);
    btPlay.sizeToFit();
    btPlay.center.x = (self.view.frame.width / 2);
    btPlay.center.y = (self.view.frame.height / 2);
    self.view.addSubview(btPlay);

    looper.initialize();

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func onClickedPlay( sender: UIButton ) {
    if ( playing ) {
      btPlay.setTitle("PLAY", forState: UIControlState.Normal);
      btPlay.setTitle("PLAY", forState: UIControlState.Highlighted);
      btPlay.sizeToFit();
      playing = false;

      looper.end();
    } else {
      btPlay.setTitle("STOP", forState: UIControlState.Normal);
      btPlay.setTitle("STOP", forState: UIControlState.Highlighted);
      btPlay.sizeToFit();
      playing = true;

      looper.start();
    }
  }


}


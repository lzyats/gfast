/*
* @desc:鍚庡彴璺敱
* @company:浜戝崡濂囪绉戞妧鏈夐檺鍏徃
* @Author: yixiaohu
* @Date:   2022/2/18 17:34
 */

package router

import (
	"context"
	"github.com/gogf/gf/v2/net/ghttp"
	systemApi "github.com/tiger1103/gfast/v3/api/v1/system"
	"github.com/tiger1103/gfast/v3/internal/app/system/controller"
	"github.com/tiger1103/gfast/v3/internal/app/system/service"
	"github.com/tiger1103/gfast/v3/library/libRouter"
)

var R = new(Router)

type Router struct{}

func (router *Router) BindController(ctx context.Context, group *ghttp.RouterGroup) {
	group.Group("/system", func(group *ghttp.RouterGroup) {
		group.Bind(
			//鐧诲綍
			controller.Login,
		)
		group.GET("/notice/ws", func(r *ghttp.Request) {
			_, _ = controller.Notice.Ws(r.Context(), &systemApi.NoticeWsReq{Token: r.Get("token").String()})
		})
		//鐧诲綍楠岃瘉鎷︽埅
		service.GfToken().Middleware(group)
		//context鎷︽埅鍣?		group.Middleware(service.Middleware().Ctx, service.Middleware().Auth)
		//鍚庡彴鎿嶄綔鏃ュ織璁板綍
		group.Hook("/*", ghttp.HookAfterOutput, service.OperateLog().OperationLog)
		group.Bind(
			controller.User,
			controller.Menu,
			controller.Role,
			controller.Dept,
			controller.Post,
			controller.DictType,
			controller.DictData,
			controller.Config,
			controller.Upload,
			controller.Notice,
			controller.Monitor,
			controller.LoginLog,
			controller.OperLog,
			controller.Personal,
			controller.UserOnline,
			controller.Cache, // 缂撳瓨澶勭悊
		)
		//鑷姩缁戝畾瀹氫箟鐨勬帶鍒跺櫒
		if err := libRouter.RouterAutoBind(ctx, router, group); err != nil {
			panic(err)
		}
	})
}

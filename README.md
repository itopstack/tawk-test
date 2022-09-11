# tawk-test

This project is compiled by latest Xcode version (13.4.1)

- [x] All of mandatory requirements are done.
- [x] Heavily unit tests (some is flaky test).

Here is bonus points that have been selected in this project.

- [ ] Empty views such as list items (while data is still loading) should have Loading Shimmer aka Skeletons ~ https://miro.medium.com/max/4000/0*s7uxK77a0FY43NLe.png resembling final views.
- [ ] Exponential backoff must be used when trying to reload the data.
- [x] Any data fetch should utilize Result types.
- [ ] CoreData stack implementation must use two managed contexts - 1.main context to be used for reading data and feeding into UI 2. write (background) context - that is used for writing data.
- [x] All CoreData write queries must be queued while allowing one concurrent query at
any time.
- [x] Coordinator and/or MVVM patterns are used.
- [x] Users list UI must be done in code and Profile - with Interface Builder.
- [ ] Items in users list are greyed out a bit for seen profiles (seen status being saved to
db).
- [ ] The app has to support dark mode.


There are still many things could be improved but I am running out ot time. :)

If you have any question, please let me know.

Regards, </br>
Kittisak Phetrungnapha </br>
cs.sealsoul@gmail.com

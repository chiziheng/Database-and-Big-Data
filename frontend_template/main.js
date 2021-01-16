const BASEURL = "[[1]]";
var HAS_REVIEW;

var Main = {
  data() {
    return {
      search_text: "",
      showDetails: false,
      showAddBook: false,
      detailData: [],
      bookData: [],
      tableData: [],
      currentReqUrl: "",
      currentOffset: 0,
      showNextPage: false,
    };
  },
  methods: {
    sortReview: function () {
      // console.log(localStorage.getItem("asin"))
      _that = this;
      this.detailData = this.detailData.filter((element) => {
        return element.label != "Reviews" && element.label != "";
      });
      var temp = "";
      if (localStorage.getItem("sort") == "false") {
        localStorage.setItem("sort", "true");
        temp = "&sortby=time";
      } else {
        localStorage.setItem("sort", "false");
        temp = "";
      }
      axios
        .get(
          BASEURL + "/readreview/?asin=" + localStorage.getItem("asin") + temp
        )
        .then(function (res) {
          res = res.data;
          HAS_REVIEW = false;
          res.forEach((element) => {
            if (!HAS_REVIEW) {
              _that.detailData.push({
                label: "Reviews",
                value: element.review,
              });
              HAS_REVIEW = true;
            } else {
              _that.detailData.push({ label: "", value: element.review });
            }
          });
        })
        .catch();
    },
    decodeHtml: function (html) {
      var txt = document.createElement("textarea");
      txt.innerHTML = html;
      if (txt.value == "undefined") {
        return "-";
      }
      return txt.value;
    },
    clearSearchResult: function () {
      this.tableData = [];
    },
    loadNextPage: function () {
      this.currentOffset += 50;
      var _that = this;
      axios
        .get(this.currentReqUrl + "&offset=" + this.currentOffset)
        .then(function (res) {
          _that.tableData = res.data.slice(1);
          scrollTo(0, 0);
        })
        .catch(function (err) {
          console.log(err);
        });
    },
    removeSearchCategory: function () {
      var spans = document.querySelectorAll(".vxe-cell li span");
      spans.forEach((element) => {
        element.outerHTML = element.outerHTML;
      });
    },
    addSearchCategory: function () {
      this.removeSearchCategory();
      var _that = this;
      var spans = document.querySelectorAll(".vxe-cell li span");
      spans.forEach((element) => {
        element.addEventListener("click", function () {
          var cate = this.innerText.replace(">", "");
          _that.currentReqUrl =
            BASEURL + "/readbook/?category=" + encodeURIComponent(cate);
          _that.currentOffset = 0;
          axios
            .get(BASEURL + "/readbook/?category=" + encodeURIComponent(cate))
            .then(function (res) {
              _that.tableData = res.data.slice(1);
              if (parseInt(res.data[0]) > 50) {
                _that.showNextPage = true;
              } else {
                _that, (showNextPage = false);
              }
              document.querySelector(".result_conut").innerHTML =
                "<i>" + res.data[0] + " results" + "</i>";
              document.querySelector("span.search_info").innerHTML =
                "Result for <i>category </i>: " + cate;
              setTimeout(function () {
                _that.addSearchCategory();
              }, 1500);
            })
            .catch(function (err) {
              console.log(err);
            });
        });
      });
    },
    search_book: function () {
      var _that = this;
      if (this.search_text == "") {
        return;
      }
      _that.showNextPage = false;
      document.querySelector("span.search_info").innerHTML =
        "Result for <i>title </i>: " + this.search_text;
      this.clearSearchResult();
      _that.currentReqUrl = BASEURL + "/readbook/?title=" + this.search_text;
      _that.currentOffset = 0;
      axios
        .get(BASEURL + "/readbook/?title=" + this.search_text)
        .then(function (res) {
          res = res.data;
          if (parseInt(res[0]) > 50) {
            _that.showNextPage = true;
          }
          document.querySelector(".result_conut").innerHTML =
            "<i>" + res[0] + " results" + "</i>";
          _that.tableData = res.slice(1);
          setTimeout(function () {
            _that.addSearchCategory();
          }, 1000);
        })
        .catch(function (err) {
          console.log(err);
        });
    },
    viewDetails: function ({ row, column }) {
      if (column.property == "categories") {
        return;
      }
      // add reviews here
      var _that = this;
      console.log(row);
      // click to close, if the detail window is already open
      if (this.showDetails) {
        this.showDetails = false;
        return;
      }
      this.detailData = ["asin", "title", "imUrl", "description", "price"].map(
        (field) => {
          return { label: field, value: row[field] };
        }
      );
      localStorage.setItem("asin", row["asin"]);
      localStorage.setItem("sort", "false");
      axios
        .get(BASEURL + "/readreview/?asin=" + row["asin"])
        .then(function (res) {
          res = res.data;
          HAS_REVIEW = false;
          res.forEach((element) => {
            if (!HAS_REVIEW) {
              _that.detailData.push({
                label: "Reviews",
                value: element.review,
              });
              HAS_REVIEW = true;
            } else {
              _that.detailData.push({ label: "", value: element.review });
            }
          });
        })
        .catch();
      this.showDetails = true;
    },
    addReview: function () {
      var _that = this;
      var bookAsin = document
        .querySelectorAll(".viewDetail td")[1]
        .querySelector("span").innerText;
      var reviewContent = document.querySelector(".reviewContent");
      if (reviewContent.value == "") {
        return;
      }
      console.log(reviewContent);
      axios
        .get(
          BASEURL +
            "/addreview/" +
            "?asin=" +
            bookAsin +
            "&content=" +
            reviewContent.value
        )
        .then(function (res) {
          if (HAS_REVIEW) {
            _that.detailData.push({ label: "", value: reviewContent.value });
          } else {
            _that.detailData.push({
              label: "Reviews",
              value: reviewContent.value,
            });
            HAS_REVIEW = true;
          }
          reviewContent.value = "";
          alert("Successfully add a review");
        })
        .catch(function (err) {
          console.log(err);
        });
    },
    addBook: function () {
      this.clearSearchResult();
      this.bookData = ["asin", "title", "imUrl", "description"].map((field) => {
        return { label: field, value: "" };
      });
      this.showAddBook = true;
      setTimeout(function () {
        document
          .querySelectorAll(".addBookPage.vxe-table .col--edit span")
          .forEach((element) => {
            element.innerText = "";
          });
      }, 100);
    },
    getAddBook: function () {
      var spans = document.querySelectorAll(
        ".addBookPage.vxe-table .col--edit span"
      );
      if (spans[0].innerText != "　" && spans[0].innerText != "") {
        axios
          .get(
            BASEURL +
              "/addbook/?asin=" +
              spans[0].innerText +
              "&title=" +
              spans[1].innerText +
              "&imUrl=" +
              spans[2].innerText +
              "&description=" +
              spans[3].innerText
          )
          .then(function () {
            console.log("add book success");
            spans.forEach((element) => {
              element.innerText = "";
            });
            alert("Add book success");
          });
      }
    },
  },
};

var Ctor = Vue.extend(Main);
var app = new Ctor().$mount("#app");

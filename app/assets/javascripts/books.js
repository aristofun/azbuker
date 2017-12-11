// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var file_input, a_reset_book_btn, div_prepared_book,
    input_lot_book_title, input_lot_book_authors,
    input_lot_bookid, input_lot_ozonid, input_lot_ozon_coverid, input_lot_ozon_flag,
    select_genre, div_suggest_form;

var typewatch_opts = {
    callback:function () {
        $.post('/suggest', {
            title:$("input#lot_book_title").val(),
            authors:$("input#lot_book_authors").val()
        });
    },
    wait:350,
    highlight:false,
    captureLength:2
};

$(document).ready(
    function () {
        file_input = $("div#file_input");
        a_reset_book_btn = $("a#reset_book_btn");
        div_prepared_book = $("div#prepared_book");
        input_lot_book_title = $("input#lot_book_title");
        input_lot_book_authors = $("input#lot_book_authors");
        input_lot_bookid = $("input#lot_bookid");
        input_lot_ozonid = $("input#lot_ozonid");
        input_lot_ozon_coverid = $("input#lot_ozon_coverid");
        input_lot_ozon_flag = $("input#lot_ozon_flag");
        select_genre = $("select#lot_book_genre");

        // New lot suggest bindings:
        $('a.suggest_btn').click(suggest_replace_fileinput);
        a_reset_book_btn.click(fileinput_replace_suggest);

        if ($("div#suggest_form").attr('data-has-suggest-flag') == 'yes') {
            turn_typewatch();
        }
    });

function turn_typewatch() {
    $("input#lot_book_title").typeWatch(typewatch_opts);
    $("input#lot_book_authors").typeWatch(typewatch_opts);
}

// restoring suggest pane with custom fileinput field
function fileinput_replace_suggest() {
    hide_suggest();

    div_prepared_book.find("img").attr('src', '');
    input_lot_bookid.attr('value', '');
    input_lot_ozonid.attr('value', '');
    input_lot_ozon_coverid.attr('value', '');
    input_lot_ozon_flag.attr('value', '');
    select_genre.attr('value', '');


    show_input();
    return false;
}


// Hiding fileinput & setting suggested book function
function suggest_replace_fileinput() {
    hide_input();

    div_prepared_book.find("img").attr('src', $(this).attr('d_src'));
    input_lot_book_title.attr('value', $(this).attr('d_title'));
    input_lot_book_authors.attr('value', $(this).attr('d_authors'));
    input_lot_bookid.attr('value', $(this).attr('d_bookid'));
    input_lot_ozonid.attr('value', $(this).attr('d_ozonid'));
    input_lot_ozon_coverid.attr('value', $(this).attr('d_ozon_coverid'));
    input_lot_ozon_flag.attr('value', $(this).attr('d_ozon_flag'));
    select_genre.attr('value', $(this).attr('d_genre'));

    show_suggest();
    return false;
}

// TOOLS:
function hide_suggest() {
    $("div#suggest_form").show();
    input_lot_book_title.attr('disabled', false);
    input_lot_book_authors.attr('disabled', false);
    select_genre.attr('disabled', false);
    a_reset_book_btn.hide();
    div_prepared_book.hide();
    div_prepared_book.detach();
}
function show_suggest() {
    div_prepared_book.show();
    div_prepared_book.appendTo("div#lot_form");
    a_reset_book_btn.show();
    input_lot_book_title.attr('disabled', true);
    input_lot_book_authors.attr('disabled', true);
    select_genre.attr('disabled', true);
    $("div#suggest_form").hide();
}
function show_input() {
    file_input.show();
    file_input.appendTo("div#lot_form");
    turn_typewatch();
}
function hide_input() {
    file_input.hide();
    file_input.detach();
}


